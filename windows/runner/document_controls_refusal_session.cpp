#include "document_controls_refusal_session.h"

namespace document_controls::windows_ipc {

Error ProcessOneRefusalSession(RefusalSessionChannel& channel) {
  if (auto error = channel.AuthenticateAndPin()) return error;
  if (auto error = channel.RecheckPeer()) return error;
  Frame request;
  if (auto error = channel.ReadRequest(&request)) return error;
  Frame refusal;
  if (auto error = BuildRefusalReply(request, &refusal)) return error;
  // No request bytes are retained in the workflow while sending the refusal.
  request = {};
  if (auto error = channel.RecheckPeer()) return error;
  if (auto error = channel.WriteRefusal(refusal)) return error;
  return channel.WaitForClientClose();
}

}  // namespace document_controls::windows_ipc
