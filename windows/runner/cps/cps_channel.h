#pragma once
#include <flutter/binary_messenger.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <memory>
#include <windows.h>

class CpsChannel {
 public:
  CpsChannel(flutter::BinaryMessenger* messenger, HWND window);
  ~CpsChannel();
  static constexpr UINT CompletionMessage = WM_APP + 0x3a2;
  void Complete();
  CpsChannel(const CpsChannel&) = delete;
  CpsChannel& operator=(const CpsChannel&) = delete;
 private:
  struct Pending;
  std::shared_ptr<Pending> pending_;
  HWND window_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};
