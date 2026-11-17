#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "win32_window.h"
#include "document_controls_channel.h"
#include "cps/cps_channel.h"
#include "webps/webps_channel.h"
#include <flutter/method_channel.h>

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

private:
    // The project to run.
    flutter::DartProject project_;

    // The Flutter instance hosted by this window.
    std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

    // Channel used by Flutter to access the Windows smart-card implementation.
    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
            smart_card_channel_;
    // Dedicated channel for Windows document controls.
    std::unique_ptr<DocumentControlsChannel> document_controls_channel_;
    std::unique_ptr<CpsChannel> cps_channel_;
    std::unique_ptr<WebPsChannel> webps_channel_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
