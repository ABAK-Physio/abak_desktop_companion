#pragma once
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <windows.h>
#include <memory>
#include "webps_browser.h"

class WebPsChannel {
 public:
  WebPsChannel(flutter::BinaryMessenger* messenger, HWND window);
  ~WebPsChannel();
  static constexpr UINT CompletionMessage = WM_APP + 0x3a3;
  void Complete();
 private:
  using Value = flutter::EncodableValue;
  using Result = flutter::MethodResult<Value>;
  struct Pending;
  void Start(const std::string& method, const std::string& url, std::unique_ptr<Result> result, const std::string& browser = {});
  abak_webps::Browser browser_;
  HWND window_;
  std::shared_ptr<Pending> pending_;
  std::unique_ptr<Result> queued_close_;
  std::unique_ptr<flutter::MethodChannel<Value>> channel_;
};
