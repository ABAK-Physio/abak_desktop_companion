
#include "document_controls_channel.h"

#include <flutter/method_call.h>
#include <flutter/method_result.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>

DocumentControlsChannel::DocumentControlsChannel(
        flutter::BinaryMessenger* messenger) {
    channel_ =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                    messenger,
                            "abak/document_controls",
                            &flutter::StandardMethodCodec::GetInstance());

    channel_->SetMethodCallHandler(
            [](const flutter::MethodCall<flutter::EncodableValue>& call,
               std::unique_ptr<
               flutter::MethodResult<flutter::EncodableValue>> result) {
                if (call.method_name() == "run") {
                    result->Error(
                            "WINDOWS_LAUNCHER_UNAVAILABLE",
                            "Le lanceur documentaire securise Windows "
                            "n'est pas encore disponible.");
                    return;
                }

                result->NotImplemented();
            });
}

DocumentControlsChannel::~DocumentControlsChannel() {
    if (channel_) {
        channel_->SetMethodCallHandler(nullptr);
    }
}
