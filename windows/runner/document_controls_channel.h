
#ifndef RUNNER_DOCUMENT_CONTROLS_CHANNEL_H_
#define RUNNER_DOCUMENT_CONTROLS_CHANNEL_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>

#include <memory>
#include <windows.h>

class DocumentControlsChannel {
public:
    explicit DocumentControlsChannel(flutter::BinaryMessenger* messenger, HWND window);
    static constexpr UINT CompletionMessage = WM_APP + 0x3a1;
    void Complete();
    ~DocumentControlsChannel();

    DocumentControlsChannel(const DocumentControlsChannel&) = delete;
    DocumentControlsChannel& operator=(const DocumentControlsChannel&) = delete;

private:
    struct Pending;
    std::shared_ptr<Pending> pending_;
    HWND window_;
    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

#endif  // RUNNER_DOCUMENT_CONTROLS_CHANNEL_H_
