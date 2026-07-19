import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private let smartCardChannelName = "abak.smart_card"

  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard
        let controller =
        mainFlutterWindow?.contentViewController as? FlutterViewController
    else {
      super.applicationDidFinishLaunching(notification)
      return
    }

    let smartCardChannel = FlutterMethodChannel(
        name: smartCardChannelName,
        binaryMessenger: controller.engine.binaryMessenger
    )

    smartCardChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "getStatus":
        result(SmartCardPcscBridge.getStatus())

      case "testApdu":
        result(SmartCardPcscBridge.testApdu())

      case "readVitaleIdentity":
        result(SmartCardPcscBridge.readVitaleIdentity())

      case "getAvailableReaders":
        result(SmartCardPcscBridge.getAvailableReaders())

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(
      _ sender: NSApplication
  ) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(
      _ app: NSApplication
  ) -> Bool {
    return true
  }
}
