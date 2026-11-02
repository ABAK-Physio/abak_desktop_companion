
#ifndef RUNNER_DOCUMENT_CONTROLS_CHANNEL_H_
#define RUNNER_DOCUMENT_CONTROLS_CHANNEL_H_

#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>

#include <memory>

class DocumentControlsChannel {
public:
    explicit DocumentControlsChannel(flutter::BinaryMessenger* messenger);
    ~DocumentControlsChannel();

    DocumentControlsChannel(const DocumentControlsChannel&) = delete;
    DocumentControlsChannel& operator=(const DocumentControlsChannel&) = delete;

private:
    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};

#endif  // RUNNER_DOCUMENT_CONTROLS_CHANNEL_H_
