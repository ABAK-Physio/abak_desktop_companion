import Cocoa
import FlutterMacOS
import Darwin

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let dmpChannel = FlutterMethodChannel(
        name: "abak_dmp_fr",
        binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    dmpChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "diagnosePkcs11":
        result(Self.diagnosePkcs11())

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }

  private static func diagnosePkcs11() -> [String: Any] {
    let libraryPath = "/usr/local/lib/libcps3_pkcs11_osx.dylib"

    guard let library = dlopen(libraryPath, RTLD_NOW) else {
      let error = dlerror().map { String(cString: $0) } ?? "Erreur inconnue"

      return [
        "success": false,
        "step": "dlopen",
        "error": error,
      ]
    }

    defer {
      dlclose(library)
    }

    guard
        let getFunctionListSymbol = dlsym(library, "C_GetFunctionList"),
        let initializeSymbol = dlsym(library, "C_Initialize"),
        let finalizeSymbol = dlsym(library, "C_Finalize"),
        let getSlotListSymbol = dlsym(library, "C_GetSlotList"),
        let getSlotInfoSymbol = dlsym(library, "C_GetSlotInfo")
    else {
      return [
        "success": false,
        "step": "dlsym",
        "error": "Un ou plusieurs symboles PKCS#11 sont introuvables",
      ]
    }

    typealias CGetFunctionList = @convention(c) (
        UnsafeMutablePointer<UnsafeMutableRawPointer?>?
    ) -> UInt

    typealias CInitialize = @convention(c) (
        UnsafeMutableRawPointer?
    ) -> UInt

    typealias CFinalize = @convention(c) (
        UnsafeMutableRawPointer?
    ) -> UInt

    typealias CGetSlotList = @convention(c) (
        UInt8,
        UnsafeMutablePointer<UInt>?,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

    struct CKVersion {
      var major: UInt8
      var minor: UInt8
    }

    struct CKSlotInfo {
      var slotDescription: (
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
      )

      var manufacturerID: (
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
      )

      var flags: UInt
      var hardwareVersion: CKVersion
      var firmwareVersion: CKVersion
    }

    typealias CGetSlotInfo = @convention(c) (
        UInt,
        UnsafeMutableRawPointer?
    ) -> UInt

    let cGetFunctionList = unsafeBitCast(
        getFunctionListSymbol,
        to: CGetFunctionList.self
    )

    let cInitialize = unsafeBitCast(
        initializeSymbol,
        to: CInitialize.self
    )

    let cFinalize = unsafeBitCast(
        finalizeSymbol,
        to: CFinalize.self
    )

    let cGetSlotList = unsafeBitCast(
        getSlotListSymbol,
        to: CGetSlotList.self
    )

    let cGetSlotInfo = unsafeBitCast(
        getSlotInfoSymbol,
        to: CGetSlotInfo.self
    )

    var functionList: UnsafeMutableRawPointer?

    let getFunctionListResult = cGetFunctionList(&functionList)

    guard getFunctionListResult == 0, functionList != nil else {
      return [
        "success": false,
        "step": "C_GetFunctionList",
        "returnCode": getFunctionListResult,
      ]
    }

    let initializeResult = cInitialize(nil)

    guard initializeResult == 0 else {
      return [
        "success": false,
        "step": "C_Initialize",
        "returnCode": initializeResult,
        "libraryPath": libraryPath,
      ]
    }

    defer {
      _ = cFinalize(nil)
    }

    var slotCount: UInt = 0

    let slotCountResult = cGetSlotList(
        0,
        nil,
        &slotCount
    )

    guard slotCountResult == 0 else {
      return [
        "success": false,
        "step": "C_GetSlotList(all)",
        "returnCode": slotCountResult,
      ]
    }

    var slotIds = Array<UInt>(
        repeating: 0,
        count: Int(slotCount)
    )

    if slotCount > 0 {
      let slotListResult = cGetSlotList(
          0,
          &slotIds,
          &slotCount
      )

      guard slotListResult == 0 else {
        return [
          "success": false,
          "step": "C_GetSlotList(ids)",
          "returnCode": slotListResult,
        ]
      }
    }

    var tokenSlotCount: UInt = 0

    let tokenSlotCountResult = cGetSlotList(
        1,
        nil,
        &tokenSlotCount
    )

    guard tokenSlotCountResult == 0 else {
      return [
        "success": false,
        "step": "C_GetSlotList(tokenPresent)",
        "returnCode": tokenSlotCountResult,
      ]
    }

    var slotDescription = ""
    var manufacturer = ""
    var slotInfoReturnCode: UInt = 0

    if let firstSlotId = slotIds.first {
      var slotInfo = CKSlotInfo(
          slotDescription: (
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0
          ),
          manufacturerID: (
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0
          ),
          flags: 0,
          hardwareVersion: CKVersion(major: 0, minor: 0),
          firmwareVersion: CKVersion(major: 0, minor: 0)
      )

      slotInfoReturnCode = withUnsafeMutablePointer(to: &slotInfo) { pointer in
        cGetSlotInfo(
            firstSlotId,
            UnsafeMutableRawPointer(pointer)
        )
      }

      if slotInfoReturnCode == 0 {
        withUnsafeBytes(of: &slotInfo.slotDescription) { bytes in
          slotDescription = String(
              bytes: bytes,
              encoding: .utf8
          )?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }

        withUnsafeBytes(of: &slotInfo.manufacturerID) { bytes in
          manufacturer = String(
              bytes: bytes,
              encoding: .utf8
          )?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
      }
    }

    return [
      "success": true,
      "step": "C_GetSlotInfo",
      "returnCode": 0,
      "slotCount": slotCount,
      "tokenSlotCount": tokenSlotCount,
      "slotId": slotIds.isEmpty ? 0 : slotIds[0],
      "slotInfoReturnCode": slotInfoReturnCode,
      "slotDescription": slotDescription,
      "manufacturer": manufacturer,
      "libraryPath": libraryPath,
    ]
  }
}