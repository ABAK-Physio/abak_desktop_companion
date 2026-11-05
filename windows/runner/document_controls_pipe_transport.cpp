#include "document_controls_pipe_transport.h"

#include <algorithm>
#include <array>
#include <utility>

namespace document_controls::windows_ipc {
namespace {
Error OsError(const char* action, DWORD code) {
  const char* kind = code == ERROR_ACCESS_DENIED ? "PIPE_ACCESS_DENIED" :
      (code == ERROR_BROKEN_PIPE || code == ERROR_NO_DATA ||
       code == ERROR_PIPE_NOT_CONNECTED) ? "PIPE_DISCONNECTED" : "PIPE_IO_FAILED";
  return {kind, std::string(action) + " (" + std::to_string(code) + ")"};
}

Error Complete(HANDLE pipe, OVERLAPPED* operation, IoBudget* budget, DWORD* count) {
  const auto remaining = budget->Remaining(GetTickCount64());
  const auto waited = remaining ? WaitForSingleObject(operation->hEvent, remaining)
                                : WAIT_TIMEOUT;
  if (waited != WAIT_OBJECT_0) {
    const DWORD error = waited == WAIT_FAILED ? GetLastError() : ERROR_TIMEOUT;
    // CancelIoEx requests cancellation, but does not complete it. Keep the event,
    // OVERLAPPED, and buffer alive until the kernel has completed this request.
    CancelIoEx(pipe, operation);
    DWORD ignored = 0;
    GetOverlappedResult(pipe, operation, &ignored, TRUE);
    if (waited == WAIT_TIMEOUT) return {"PIPE_TIMEOUT", "Pipe deadline expired."};
    return OsError("WaitForSingleObject", error);
  }
  if (!GetOverlappedResult(pipe, operation, count, FALSE)) {
    return OsError("GetOverlappedResult", GetLastError());
  }
  if (budget->Remaining(GetTickCount64()) == 0) {
    return {"PIPE_TIMEOUT", "Pipe deadline expired."};
  }
  return {};
}

Error Transfer(HANDLE pipe, std::uint8_t* bytes, std::size_t size,
               IoBudget* budget, bool writing) {
  if (!budget || (size && !bytes)) {
    return {"INVALID_ARGUMENTS", "Missing pipe transfer arguments."};
  }
  while (size) {
    if (budget->Remaining(GetTickCount64()) == 0) {
      return {"PIPE_TIMEOUT", "Pipe deadline expired."};
    }
    OwnedHandle event(CreateEventW(nullptr, TRUE, FALSE, nullptr));
    if (!event) return OsError("CreateEventW", GetLastError());
    OVERLAPPED operation{};
    operation.hEvent = event.get();
    DWORD count = 0;
    const DWORD part = static_cast<DWORD>((std::min)(size, std::size_t{65536}));
    const BOOL immediate = writing ? WriteFile(pipe, bytes, part, &count, &operation)
                                   : ReadFile(pipe, bytes, part, &count, &operation);
    if (!immediate) {
      const auto code = GetLastError();
      if (code != ERROR_IO_PENDING) return OsError("Pipe transfer", code);
      if (auto error = Complete(pipe, &operation, budget, &count)) return error;
    } else if (!GetOverlappedResult(pipe, &operation, &count, FALSE)) {
      return OsError("GetOverlappedResult", GetLastError());
    }
    if (count == 0 || count > part) {
      return {"PIPE_DISCONNECTED", "Pipe ended before the frame was complete."};
    }
    if (budget->Remaining(GetTickCount64()) == 0) {
      return {"PIPE_TIMEOUT", "Pipe deadline expired."};
    }
    budget->Progress(GetTickCount64());
    bytes += count;
    size -= count;
  }
  return {};
}
}  // namespace

OwnedHandle::~OwnedHandle() { reset(); }
OwnedHandle::OwnedHandle(OwnedHandle&& other) noexcept : handle_(other.handle_) {
  other.handle_ = INVALID_HANDLE_VALUE;
}
OwnedHandle& OwnedHandle::operator=(OwnedHandle&& other) noexcept {
  if (this != &other) { reset(other.handle_); other.handle_ = INVALID_HANDLE_VALUE; }
  return *this;
}
void OwnedHandle::reset(HANDLE handle) {
  if (*this) CloseHandle(handle_);
  handle_ = handle;
}

Error OpenLocalPipe(const std::wstring& name, OwnedHandle* pipe) {
  if (!pipe) return {"INVALID_ARGUMENTS", "Missing pipe output."};
  pipe->reset();
  const std::wstring prefix = L"\\\\.\\pipe\\ABAK.DocumentControls.";
  if (name.size() > 256 || name.compare(0, prefix.size(), prefix) != 0 ||
      name.find(L'\\', prefix.size()) != std::wstring::npos ||
      name.find(L'\0') != std::wstring::npos) {
    return {"INVALID_PIPE_NAME", "Only ABAK local named pipes are allowed."};
  }
  const auto end = GetTickCount64() + kConnectTimeoutMs;
  for (;;) {
    // Do not request GENERIC_WRITE: it includes FILE_CREATE_PIPE_INSTANCE.
    pipe->reset(CreateFileW(name.c_str(), FILE_READ_DATA | FILE_WRITE_DATA |
        FILE_READ_ATTRIBUTES | SYNCHRONIZE, 0, nullptr, OPEN_EXISTING,
        FILE_FLAG_OVERLAPPED | SECURITY_SQOS_PRESENT | SECURITY_IDENTIFICATION,
        nullptr));
    if (*pipe) return {};
    const auto code = GetLastError();
    if (code == ERROR_FILE_NOT_FOUND) return {"SERVICE_ABSENT", "Pipe not present."};
    if (code != ERROR_PIPE_BUSY) return OsError("CreateFileW", code);
    const auto now = GetTickCount64();
    if (now >= end) return {"PIPE_BUSY", "No pipe instance became available."};
    WaitNamedPipeW(name.c_str(), static_cast<DWORD>((std::min)(end - now, ULONGLONG{50})));
  }
}

Error AcceptPipe(HANDLE pipe, IoBudget* budget) {
  if (!budget || budget->Remaining(GetTickCount64()) == 0) {
    return {"PIPE_TIMEOUT", "Pipe connection deadline expired."};
  }
  OwnedHandle event(CreateEventW(nullptr, TRUE, FALSE, nullptr));
  if (!event) return OsError("CreateEventW", GetLastError());
  OVERLAPPED operation{};
  operation.hEvent = event.get();
  if (!ConnectNamedPipe(pipe, &operation)) {
    const auto code = GetLastError();
    if (code == ERROR_PIPE_CONNECTED) { budget->Progress(GetTickCount64()); return {}; }
    if (code != ERROR_IO_PENDING) return OsError("ConnectNamedPipe", code);
    DWORD ignored = 0;
    if (auto error = Complete(pipe, &operation, budget, &ignored)) return error;
  }
  budget->Progress(GetTickCount64());
  return {};
}

Error PipeReadExact(HANDLE pipe, std::uint8_t* bytes, std::size_t size,
                    IoBudget* budget) { return Transfer(pipe, bytes, size, budget, false); }
Error PipeWriteExact(HANDLE pipe, const std::uint8_t* bytes, std::size_t size,
                     IoBudget* budget) {
  return Transfer(pipe, const_cast<std::uint8_t*>(bytes), size, budget, true);
}

Error ReadPipeFrame(HANDLE pipe, Direction direction, IoBudget* budget, Frame* frame) {
  if (!frame) return {"INVALID_ARGUMENTS", "Missing frame output."};
  *frame = {};
  std::array<std::uint8_t, kPrefixBytes> prefix{};
  if (auto error = PipeReadExact(pipe, prefix.data(), prefix.size(), budget)) return error;
  FrameSizes sizes;
  if (auto error = DecodePrefix(prefix.data(), prefix.size(), direction, &sizes)) return error;
  // Both lengths were checked before allocating any body bytes.
  Frame received;
  received.metadata.resize(sizes.metadata);
  received.payload.resize(static_cast<std::size_t>(sizes.payload));
  if (auto error = PipeReadExact(pipe,
      reinterpret_cast<std::uint8_t*>(&received.metadata[0]), sizes.metadata, budget)) return error;
  if (!ValidUtf8(received.metadata)) return {"INVALID_METADATA", "Invalid UTF-8 metadata."};
  if (auto error = PipeReadExact(pipe, received.payload.data(), received.payload.size(), budget)) return error;
  *frame = std::move(received);
  return {};
}

Error WritePipeFrame(HANDLE pipe, const Frame& frame, Direction direction, IoBudget* budget) {
  std::vector<std::uint8_t> bytes;
  if (auto error = EncodeFrame(frame, direction, &bytes)) return error;
  return PipeWriteExact(pipe, bytes.data(), bytes.size(), budget);
}

}  // namespace document_controls::windows_ipc
