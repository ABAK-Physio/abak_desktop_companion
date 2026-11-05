#ifndef RUNNER_DOCUMENT_CONTROLS_PIPE_TRANSPORT_H_
#define RUNNER_DOCUMENT_CONTROLS_PIPE_TRANSPORT_H_

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include "document_controls_peer_policy.h"

namespace document_controls::windows_ipc {

class OwnedHandle {
 public:
  OwnedHandle() = default;
  explicit OwnedHandle(HANDLE handle) : handle_(handle) {}
  ~OwnedHandle();
  OwnedHandle(const OwnedHandle&) = delete;
  OwnedHandle& operator=(const OwnedHandle&) = delete;
  OwnedHandle(OwnedHandle&& other) noexcept;
  OwnedHandle& operator=(OwnedHandle&& other) noexcept;
  HANDLE get() const { return handle_; }
  explicit operator bool() const {
    return handle_ && handle_ != INVALID_HANDLE_VALUE;
  }
  void reset(HANDLE handle = INVALID_HANDLE_VALUE);
 private:
  HANDLE handle_ = INVALID_HANDLE_VALUE;
};

// Low-level byte transport only: these functions do not grant authorization or
// execute an operation. Production Exchange() and all W1 gates stay closed.
Error OpenLocalPipe(const std::wstring& name, OwnedHandle* pipe);
Error AcceptPipe(HANDLE pipe, IoBudget* budget);
Error PipeReadExact(HANDLE pipe, std::uint8_t* bytes, std::size_t size,
                    IoBudget* budget);
Error PipeWriteExact(HANDLE pipe, const std::uint8_t* bytes, std::size_t size,
                     IoBudget* budget);
Error ReadPipeFrame(HANDLE pipe, Direction direction, IoBudget* budget,
                    Frame* frame);
Error WritePipeFrame(HANDLE pipe, const Frame& frame, Direction direction,
                     IoBudget* budget);

}  // namespace document_controls::windows_ipc

#endif  // RUNNER_DOCUMENT_CONTROLS_PIPE_TRANSPORT_H_
