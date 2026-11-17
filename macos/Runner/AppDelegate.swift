import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var quitPending = false

  override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    if quitPending { return .terminateLater }
    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return .terminateNow
    }
    quitPending = true
    // AppKit owns this asynchronous handshake. Do not re-enter Flutter's
    // cancel/reissue termination loop after Dart has drained its services.
    let channel = FlutterMethodChannel(name: "abak/application_lifecycle",
                                      binaryMessenger: controller.engine.binaryMessenger)
    channel.invokeMethod("prepareToQuit", arguments: nil) { [weak self] response in
      DispatchQueue.main.async {
        self?.quitPending = false
        let allowed = (response as? Bool) ?? !(response is FlutterError)
        sender.reply(toApplicationShouldTerminate: allowed)
      }
    }
    return .terminateLater
  }

  override func applicationShouldTerminateAfterLastWindowClosed(
      _ sender: NSApplication
  ) -> Bool {
    return true
  }

  override func applicationWillTerminate(_ notification: Notification) {
    WebPsBrowserBridge.shared.terminateOwnedBrowser()
    super.applicationWillTerminate(notification)
  }

  override func applicationSupportsSecureRestorableState(
      _ app: NSApplication
  ) -> Bool {
    return true
  }
}