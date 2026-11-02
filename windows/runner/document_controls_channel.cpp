#include "document_controls_launcher.h"
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
                    const auto* arguments =
                            std::get_if<flutter::EncodableMap>(call.arguments());

                    if (arguments == nullptr) {
                        result->Error(
                                "INVALID_ARGUMENTS",
                                "Parametres documentaires absents ou invalides.");
                        return;
                    }

                    const auto it = arguments->find(
                            flutter::EncodableValue("operation"));

                    if (it == arguments->end() ||
                        !std::holds_alternative<std::string>(it->second)) {
                        result->Error(
                                "INVALID_OPERATION",
                                "Operation documentaire absente.");
                        return;
                    }

                    document_controls::Operation operation;

                    if (!document_controls::ParseOperation(
                            std::get<std::string>(it->second),
                            &operation)) {
                        result->Error(
                                "INVALID_OPERATION",
                                "Operation documentaire non autorisee.");
                        return;
                    }

                    const auto launch = document_controls::Launch(operation);

                    result->Error(launch.error_code, launch.message);
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
