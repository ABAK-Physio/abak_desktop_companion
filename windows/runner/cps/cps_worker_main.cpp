#include "cps_pkcs11_windows.h"
#include "cps_wire.h"
#include <windows.h>
#include <werapi.h>
#include <cerrno>
#include <cstdlib>
#include <limits>

namespace {
HANDLE ParseHandle(const wchar_t* value) {
  wchar_t* end = nullptr; errno = 0;
  const auto number = std::wcstoull(value, &end, 10);
  if (errno || !end || *end || number == 0 ||
      number > (std::numeric_limits<std::uintptr_t>::max)()) return nullptr;
  return reinterpret_cast<HANDLE>(static_cast<std::uintptr_t>(number));
}
bool Read(HANDLE handle, void* data, DWORD size) {
  auto* bytes = static_cast<cps_windows::Byte*>(data);
  while (size) {
    DWORD count = 0;
    if (!ReadFile(handle, bytes, size, &count, nullptr) || !count) return false;
    size -= count; bytes += count;
  }
  return true;
}
bool Write(HANDLE handle, const void* data, DWORD size) {
  const auto* bytes = static_cast<const cps_windows::Byte*>(data);
  while (size) {
    DWORD count = 0;
    if (!WriteFile(handle, bytes, size, &count, nullptr) || !count) return false;
    size -= count; bytes += count;
  }
  return true;
}
}
int wmain(int argc, wchar_t** argv) {
  SetErrorMode(SEM_FAILCRITICALERRORS);
  WerSetFlags(WER_FAULT_REPORTING_NO_UI);
  if (argc != 3) return 2;
  const HANDLE input = ParseHandle(argv[1]), output = ParseHandle(argv[2]);
  if (GetFileType(input) != FILE_TYPE_PIPE || GetFileType(output) != FILE_TYPE_PIPE) return 2;
  cps_windows::Header request{}; std::uint32_t size = 0;
  if (!Read(input, request.data(), static_cast<DWORD>(request.size())) ||
      !cps_windows::ParseHeader(request, false, &size)) return 3;
  std::vector<cps_windows::Byte> bytes(size);
  if (!Read(input, bytes.data(), size)) { cps_windows::Erase(&bytes); return 3; }
  cps_windows::Request command;
  const bool valid = cps_windows::DecodeRequest(bytes, &command);
  cps_windows::Erase(&bytes);
  if (!valid) return 3;
  const auto operation = command.operation;
  auto reply = cps_windows::ReadInstalledCryptolib(std::move(command));
  reply.operation = operation;
  std::vector<cps_windows::Byte> payload;
  if (!cps_windows::Encode(reply, &payload)) return 4;
  const auto header = cps_windows::MakeHeader(true, static_cast<std::uint32_t>(payload.size()));
  if (!Write(output, header.data(), static_cast<DWORD>(header.size())) ||
      !Write(output, payload.data(), static_cast<DWORD>(payload.size()))) return 5;
  return 0;
}
