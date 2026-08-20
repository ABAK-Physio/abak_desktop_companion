import Cocoa
import FlutterMacOS
import Darwin
import Security

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

      case "loginPkcs11User":
        guard
            let arguments = call.arguments as? [String: Any],
            let pin = arguments["pin"] as? String
        else {
          result(
              FlutterError(
                  code: "INVALID_ARGUMENTS",
                  message: "PIN CPS absent",
                  details: nil
              )
          )
          return
        }

        result(Self.loginPkcs11User(pin: pin))

      case "listPkcs11Objects":
        guard
            let arguments = call.arguments as? [String: Any],
            let pin = arguments["pin"] as? String
        else {
          result(
              FlutterError(
                  code: "INVALID_ARGUMENTS",
                  message: "PIN CPS absent",
                  details: nil
              )
          )
          return
        }

        result(Self.listPkcs11Objects(pin: pin))

      case "getPkcs11SigningCertificate":
        guard
            let arguments = call.arguments as? [String: Any],
            let pin = arguments["pin"] as? String
        else {
          result(
              FlutterError(
                  code: "INVALID_ARGUMENTS",
                  message: "PIN CPS absent",
                  details: nil
              )
          )
          return
        }

        result(Self.getPkcs11SigningCertificate(pin: pin))

      case "signPkcs11TestMessage":
        guard
            let arguments = call.arguments as? [String: Any],
            let pin = arguments["pin"] as? String
        else {
          result(
              FlutterError(
                  code: "INVALID_ARGUMENTS",
                  message: "PIN CPS absent",
                  details: nil
              )
          )
          return
        }

        result(
            Self.signPkcs11Message(
                pin: pin,
                message: "ABAK_TEST_SIGNATURE"
            )
        )

      case "signInsiPsAssertion":
        guard
            let arguments = call.arguments as? [String: Any],
            let canonicalSignedInfo =
            arguments["canonicalSignedInfo"] as? String
        else {
          result(
              FlutterError(
                  code: "INVALID_ARGUMENTS",
                  message: "SignedInfo canonisé absent",
                  details: nil
              )
          )
          return
        }

        let signatureResult = Self.signPkcs11Message(
            pin: "1234",
            message: canonicalSignedInfo
        )

        guard
            signatureResult["success"] as? Bool == true,
            let signatureBase64 =
            signatureResult["signatureBase64"] as? String
        else {
          result(
              FlutterError(
                  code: "CPS_SIGNATURE_FAILED",
                  message: "Échec de la signature CPS",
                  details: signatureResult
              )
          )
          return
        }

        result(signatureBase64)

      case "verifyInsiPsSignature":
        guard
            let arguments = call.arguments as? [String: Any],
            let canonicalSignedInfo =
            arguments["canonicalSignedInfo"] as? String,
            let signatureBase64 =
            arguments["signatureBase64"] as? String,
            let certificateBase64 =
            arguments["certificateBase64"] as? String
        else {
          result(
              FlutterError(
                  code: "INVALID_ARGUMENTS",
                  message: "Données de vérification absentes",
                  details: nil
              )
          )
          return
        }

        result(
            Self.verifyInsiPsSignature(
                canonicalSignedInfo: canonicalSignedInfo,
                signatureBase64: signatureBase64,
                certificateBase64: certificateBase64
            )
        )

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
        let getSlotInfoSymbol = dlsym(library, "C_GetSlotInfo"),
        let getTokenInfoSymbol = dlsym(library, "C_GetTokenInfo"),
        let openSessionSymbol = dlsym(library, "C_OpenSession"),
        let getSessionInfoSymbol = dlsym(library, "C_GetSessionInfo"),
        let closeSessionSymbol = dlsym(library, "C_CloseSession")
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

    typealias CGetSlotInfo = @convention(c) (
        UInt,
        UnsafeMutableRawPointer?
    ) -> UInt

    typealias CGetTokenInfo = @convention(c) (
        UInt,
        UnsafeMutableRawPointer?
    ) -> UInt

    typealias COpenSession = @convention(c) (
        UInt,
        UInt,
        UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

    typealias CGetSessionInfo = @convention(c) (
        UInt,
        UnsafeMutableRawPointer?
    ) -> UInt

    typealias CCloseSession = @convention(c) (
        UInt
    ) -> UInt

    struct CKSessionInfo {
      var slotID: UInt
      var state: UInt
      var flags: UInt
      var deviceError: UInt
    }

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

    struct CKTokenInfo {
      var label: (
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

      var model: (
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
      )

      var serialNumber: (
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
      )

      var flags: UInt
      var maxSessionCount: UInt
      var sessionCount: UInt
      var maxRwSessionCount: UInt
      var rwSessionCount: UInt
      var maxPinLen: UInt
      var minPinLen: UInt
      var totalPublicMemory: UInt
      var freePublicMemory: UInt
      var totalPrivateMemory: UInt
      var freePrivateMemory: UInt
      var hardwareVersion: CKVersion
      var firmwareVersion: CKVersion

      var utcTime: (
          UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8,
          UInt8, UInt8, UInt8, UInt8
      )
    }

    let cGetFunctionList = unsafeBitCast(
        getFunctionListSymbol,
        to: CGetFunctionList.self
    )

    let cOpenSession = unsafeBitCast(
        openSessionSymbol,
        to: COpenSession.self
    )

    let cGetSessionInfo = unsafeBitCast(
        getSessionInfoSymbol,
        to: CGetSessionInfo.self
    )

    let cCloseSession = unsafeBitCast(
        closeSessionSymbol,
        to: CCloseSession.self
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

    let cGetTokenInfo = unsafeBitCast(
        getTokenInfoSymbol,
        to: CGetTokenInfo.self
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

    // ------------------------------------------------------------
    // Liste de tous les slots
    // ------------------------------------------------------------

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

    // ------------------------------------------------------------
    // Liste des slots contenant un token
    // ------------------------------------------------------------

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

    var tokenSlotIds = Array<UInt>(
        repeating: 0,
        count: Int(tokenSlotCount)
    )

    if tokenSlotCount > 0 {
      let tokenSlotListResult = cGetSlotList(
          1,
          &tokenSlotIds,
          &tokenSlotCount
      )

      guard tokenSlotListResult == 0 else {
        return [
          "success": false,
          "step": "C_GetSlotList(tokenIds)",
          "returnCode": tokenSlotListResult,
        ]
      }
    }

    // ------------------------------------------------------------
    // Informations du premier slot
    // ------------------------------------------------------------

    var slotDescription = ""
    var slotManufacturer = ""
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
          slotManufacturer = String(
              bytes: bytes,
              encoding: .utf8
          )?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
      }
    }

    // ------------------------------------------------------------
    // Informations du token présent
    // ------------------------------------------------------------

    func decodeTokenFlags(_ flags: UInt) -> [String] {
      var result: [String] = []

      if flags & 0x00000001 != 0 {
        result.append("CKF_RNG")
      }

      if flags & 0x00000002 != 0 {
        result.append("CKF_WRITE_PROTECTED")
      }

      if flags & 0x00000004 != 0 {
        result.append("CKF_LOGIN_REQUIRED")
      }

      if flags & 0x00000008 != 0 {
        result.append("CKF_USER_PIN_INITIALIZED")
      }

      if flags & 0x00000100 != 0 {
        result.append("CKF_PROTECTED_AUTHENTICATION_PATH")
      }

      if flags & 0x00000400 != 0 {
        result.append("CKF_TOKEN_INITIALIZED")
      }

      if flags & 0x00010000 != 0 {
        result.append("CKF_USER_PIN_COUNT_LOW")
      }

      if flags & 0x00020000 != 0 {
        result.append("CKF_USER_PIN_FINAL_TRY")
      }

      if flags & 0x00040000 != 0 {
        result.append("CKF_USER_PIN_LOCKED")
      }

      if flags & 0x00080000 != 0 {
        result.append("CKF_USER_PIN_TO_BE_CHANGED")
      }

      return result
    }
    var tokenInfoReturnCode: UInt = 0
    var tokenLabel = ""
    var tokenManufacturer = ""
    var tokenModel = ""
    var tokenSerialNumber = ""
    var tokenFlags: UInt = 0
    var tokenHardwareVersion = ""
    var tokenFirmwareVersion = ""

    if let tokenSlotId = tokenSlotIds.first {
      var tokenInfo = CKTokenInfo(
          label: (
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
          model: (
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0
          ),
          serialNumber: (
              0, 0, 0, 0, 0, 0, 0, 0,
              0, 0, 0, 0, 0, 0, 0, 0
          ),
          flags: 0,
          maxSessionCount: 0,
          sessionCount: 0,
          maxRwSessionCount: 0,
          rwSessionCount: 0,
          maxPinLen: 0,
          minPinLen: 0,
          totalPublicMemory: 0,
          freePublicMemory: 0,
          totalPrivateMemory: 0,
          freePrivateMemory: 0,
          hardwareVersion: CKVersion(major: 0, minor: 0),
          firmwareVersion: CKVersion(major: 0, minor: 0),
          utcTime: (
              0, 0, 0, 0,
              0, 0, 0, 0,
              0, 0, 0, 0,
              0, 0, 0, 0
          )
      )

      tokenInfoReturnCode = withUnsafeMutablePointer(to: &tokenInfo) { pointer in
        cGetTokenInfo(
            tokenSlotId,
            UnsafeMutableRawPointer(pointer)
        )
      }

      if tokenInfoReturnCode == 0 {
        withUnsafeBytes(of: &tokenInfo.label) { bytes in
          tokenLabel = String(
              bytes: bytes,
              encoding: .utf8
          )?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }

        withUnsafeBytes(of: &tokenInfo.manufacturerID) { bytes in
          tokenManufacturer = String(
              bytes: bytes,
              encoding: .utf8
          )?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }

        withUnsafeBytes(of: &tokenInfo.model) { bytes in
          tokenModel = String(
              bytes: bytes,
              encoding: .utf8
          )?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }

        withUnsafeBytes(of: &tokenInfo.serialNumber) { bytes in
          tokenSerialNumber = String(
              bytes: bytes,
              encoding: .utf8
          )?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }

        tokenFlags = tokenInfo.flags

        tokenHardwareVersion =
            "\(tokenInfo.hardwareVersion.major).\(tokenInfo.hardwareVersion.minor)"

        tokenFirmwareVersion =
            "\(tokenInfo.firmwareVersion.major).\(tokenInfo.firmwareVersion.minor)"
      }
    }

    // ------------------------------------------------------------
// Ouverture d'une session PKCS#11 en lecture seule
// ------------------------------------------------------------

    var sessionOpenReturnCode: UInt = 0
    var sessionInfoReturnCode: UInt = 0
    var closeSessionReturnCode: UInt = 0

    var sessionHandle: UInt = 0
    var sessionState: UInt = 0
    var sessionFlags: UInt = 0
    var sessionDeviceError: UInt = 0

    if let tokenSlotId = tokenSlotIds.first {
      // CKF_SERIAL_SESSION est obligatoire pour C_OpenSession.
      // L'absence de CKF_RW_SESSION donne une session en lecture seule.
      let ckfSerialSession: UInt = 0x00000004

      sessionOpenReturnCode = cOpenSession(
          tokenSlotId,
          ckfSerialSession,
          nil,
          nil,
          &sessionHandle
      )

      if sessionOpenReturnCode == 0 {
        var sessionInfo = CKSessionInfo(
            slotID: 0,
            state: 0,
            flags: 0,
            deviceError: 0
        )

        sessionInfoReturnCode =
            withUnsafeMutablePointer(to: &sessionInfo) { pointer in
              cGetSessionInfo(
                  sessionHandle,
                  UnsafeMutableRawPointer(pointer)
              )
            }

        if sessionInfoReturnCode == 0 {
          sessionState = sessionInfo.state
          sessionFlags = sessionInfo.flags
          sessionDeviceError = sessionInfo.deviceError
        }

        closeSessionReturnCode = cCloseSession(
            sessionHandle
        )
      }
    }

    return [
      "success": true,
      "step": "C_GetTokenInfo",
      "returnCode": 0,

      "slotCount": slotCount,
      "tokenSlotCount": tokenSlotCount,

      "slotId": slotIds.isEmpty ? 0 : slotIds[0],
      "slotInfoReturnCode": slotInfoReturnCode,
      "slotDescription": slotDescription,
      "slotManufacturer": slotManufacturer,

      "tokenSlotId": tokenSlotIds.isEmpty ? 0 : tokenSlotIds[0],
      "tokenInfoReturnCode": tokenInfoReturnCode,
      "tokenLabel": tokenLabel,
      "tokenManufacturer": tokenManufacturer,
      "tokenModel": tokenModel,
      "tokenSerialNumber": tokenSerialNumber,
      "tokenFlags": tokenFlags,
      "tokenFlagNames": decodeTokenFlags(tokenFlags),
      "tokenHardwareVersion": tokenHardwareVersion,
      "tokenFirmwareVersion": tokenFirmwareVersion,

      "sessionOpenReturnCode": sessionOpenReturnCode,
      "sessionHandle": sessionHandle,
      "sessionInfoReturnCode": sessionInfoReturnCode,
      "sessionState": sessionState,
      "sessionFlags": sessionFlags,
      "sessionDeviceError": sessionDeviceError,
      "closeSessionReturnCode": closeSessionReturnCode,

      "libraryPath": libraryPath,
    ]
  }
  private static func loginPkcs11User(pin: String) -> [String: Any] {
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
        let initializeSymbol = dlsym(library, "C_Initialize"),
        let finalizeSymbol = dlsym(library, "C_Finalize"),
        let getSlotListSymbol = dlsym(library, "C_GetSlotList"),
        let openSessionSymbol = dlsym(library, "C_OpenSession"),
        let getSessionInfoSymbol = dlsym(library, "C_GetSessionInfo"),
        let loginSymbol = dlsym(library, "C_Login"),
        let logoutSymbol = dlsym(library, "C_Logout"),
        let closeSessionSymbol = dlsym(library, "C_CloseSession")
    else {
      return [
        "success": false,
        "step": "dlsym",
        "error": "Un ou plusieurs symboles PKCS#11 sont introuvables",
      ]
    }

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

    typealias COpenSession = @convention(c) (
        UInt,
        UInt,
        UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

    typealias CLogin = @convention(c) (
        UInt,
        UInt,
        UnsafeMutablePointer<UInt8>?,
        UInt
    ) -> UInt

    typealias CLogout = @convention(c) (
        UInt
    ) -> UInt

    typealias CGetSessionInfo = @convention(c) (
        UInt,
        UnsafeMutableRawPointer?
    ) -> UInt

    typealias CCloseSession = @convention(c) (
        UInt
    ) -> UInt

    struct CKSessionInfo {
      var slotID: UInt
      var state: UInt
      var flags: UInt
      var deviceError: UInt
    }

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

    let cOpenSession = unsafeBitCast(
        openSessionSymbol,
        to: COpenSession.self
    )

    let cLogin = unsafeBitCast(
        loginSymbol,
        to: CLogin.self
    )

    let cLogout = unsafeBitCast(
        logoutSymbol,
        to: CLogout.self
    )

    let cGetSessionInfo = unsafeBitCast(
        getSessionInfoSymbol,
        to: CGetSessionInfo.self
    )

    let cCloseSession = unsafeBitCast(
        closeSessionSymbol,
        to: CCloseSession.self
    )

    let initializeReturnCode = cInitialize(nil)

    guard initializeReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Initialize",
        "initializeReturnCode": initializeReturnCode,
      ]
    }

    defer {
      _ = cFinalize(nil)
    }

    var tokenSlotCount: UInt = 0

    let tokenSlotCountReturnCode = cGetSlotList(
        1,
        nil,
        &tokenSlotCount
    )

    guard tokenSlotCountReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_GetSlotList(count)",
        "returnCode": tokenSlotCountReturnCode,
      ]
    }

    guard tokenSlotCount > 0 else {
      return [
        "success": false,
        "step": "C_GetSlotList",
        "error": "Aucune CPS détectée",
      ]
    }

    var tokenSlotIds = Array<UInt>(
        repeating: 0,
        count: Int(tokenSlotCount)
    )

    let tokenSlotListReturnCode = cGetSlotList(
        1,
        &tokenSlotIds,
        &tokenSlotCount
    )

    guard tokenSlotListReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_GetSlotList(ids)",
        "returnCode": tokenSlotListReturnCode,
      ]
    }

    let tokenSlotId = tokenSlotIds[0]

    let ckfSerialSession: UInt = 0x00000004

    var sessionHandle: UInt = 0

    let openSessionReturnCode = cOpenSession(
        tokenSlotId,
        ckfSerialSession,
        nil,
        nil,
        &sessionHandle
    )

    guard openSessionReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_OpenSession",
        "openSessionReturnCode": openSessionReturnCode,
      ]
    }

    defer {
      _ = cCloseSession(sessionHandle)
    }

    let ckuUser: UInt = 1

    var pinBytes = Array(pin.utf8)

    let loginReturnCode = pinBytes.withUnsafeMutableBufferPointer { buffer in
      cLogin(
          sessionHandle,
          ckuUser,
          buffer.baseAddress,
          UInt(buffer.count)
      )
    }

    guard loginReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Login",
        "loginReturnCode": loginReturnCode,
      ]
    }

    defer {
      _ = cLogout(sessionHandle)
    }

    var sessionInfo = CKSessionInfo(
        slotID: 0,
        state: 0,
        flags: 0,
        deviceError: 0
    )

    let sessionInfoReturnCode =
        withUnsafeMutablePointer(to: &sessionInfo) { pointer in
          cGetSessionInfo(
              sessionHandle,
              UnsafeMutableRawPointer(pointer)
          )
        }

    return [
      "success": sessionInfoReturnCode == 0,
      "step": "C_Login",
      "loginReturnCode": loginReturnCode,
      "sessionInfoReturnCode": sessionInfoReturnCode,
      "sessionState": sessionInfo.state,
      "sessionFlags": sessionInfo.flags,
      "sessionDeviceError": sessionInfo.deviceError,
    ]
  }

  private static func listPkcs11Objects(pin: String) -> [String: Any] {
    let libraryPath = "/usr/local/lib/libcps3_pkcs11_osx.dylib"

    // PKCS#11
    let ckuUser: UInt = 1
    let ckfSerialSession: UInt = 0x00000004

    let ckoCertificate: UInt = 1
    let ckoPrivateKey: UInt = 3

    let ckaClass: UInt = 0
    let ckaLabel: UInt = 3
    let ckaId: UInt = 0x102
    let ckaValue: UInt = 0x11

    struct CKAttribute {
      var type: UInt
      var value: UnsafeMutableRawPointer?
      var valueLen: UInt
    }

    guard let library = dlopen(libraryPath, RTLD_NOW) else {
      let error = dlerror().map {
        String(cString: $0)
      } ?? "Erreur inconnue"

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
        let initializeSymbol = dlsym(library, "C_Initialize"),
        let finalizeSymbol = dlsym(library, "C_Finalize"),
        let getSlotListSymbol = dlsym(library, "C_GetSlotList"),
        let openSessionSymbol = dlsym(library, "C_OpenSession"),
        let loginSymbol = dlsym(library, "C_Login"),
        let logoutSymbol = dlsym(library, "C_Logout"),
        let closeSessionSymbol = dlsym(library, "C_CloseSession"),
        let findObjectsInitSymbol = dlsym(library, "C_FindObjectsInit"),
        let findObjectsSymbol = dlsym(library, "C_FindObjects"),
        let findObjectsFinalSymbol = dlsym(library, "C_FindObjectsFinal"),
        let getAttributeValueSymbol = dlsym(library, "C_GetAttributeValue")
    else {
      return [
        "success": false,
        "step": "dlsym",
        "error": "Un ou plusieurs symboles PKCS#11 sont introuvables",
      ]
    }

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

    typealias COpenSession = @convention(c) (
        UInt,
        UInt,
        UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

    typealias CLogin = @convention(c) (
        UInt,
        UInt,
        UnsafeMutablePointer<UInt8>?,
        UInt
    ) -> UInt

    typealias CLogout = @convention(c) (
        UInt
    ) -> UInt

    typealias CCloseSession = @convention(c) (
        UInt
    ) -> UInt

    typealias CFindObjectsInit = @convention(c) (
        UInt,
        UnsafeMutableRawPointer?,
        UInt
    ) -> UInt

    typealias CFindObjects = @convention(c) (
        UInt,
        UnsafeMutablePointer<UInt>?,
        UInt,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

    typealias CFindObjectsFinal = @convention(c) (
        UInt
    ) -> UInt

    typealias CGetAttributeValue = @convention(c) (
        UInt,
        UInt,
        UnsafeMutableRawPointer?,
        UInt
    ) -> UInt

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

    let cOpenSession = unsafeBitCast(
        openSessionSymbol,
        to: COpenSession.self
    )

    let cLogin = unsafeBitCast(
        loginSymbol,
        to: CLogin.self
    )

    let cLogout = unsafeBitCast(
        logoutSymbol,
        to: CLogout.self
    )

    let cCloseSession = unsafeBitCast(
        closeSessionSymbol,
        to: CCloseSession.self
    )

    let cFindObjectsInit = unsafeBitCast(
        findObjectsInitSymbol,
        to: CFindObjectsInit.self
    )

    let cFindObjects = unsafeBitCast(
        findObjectsSymbol,
        to: CFindObjects.self
    )

    let cFindObjectsFinal = unsafeBitCast(
        findObjectsFinalSymbol,
        to: CFindObjectsFinal.self
    )

    let cGetAttributeValue = unsafeBitCast(
        getAttributeValueSymbol,
        to: CGetAttributeValue.self
    )

    // ------------------------------------------------------------
    // Lecture d'un attribut PKCS#11
    // ------------------------------------------------------------

    func readAttribute(
        session: UInt,
        object: UInt,
        type: UInt
    ) -> [UInt8]? {
      var attribute = CKAttribute(
          type: type,
          value: nil,
          valueLen: 0
      )

      let sizeResult =
          withUnsafeMutablePointer(to: &attribute) { pointer in
            cGetAttributeValue(
                session,
                object,
                UnsafeMutableRawPointer(pointer),
                1
            )
          }

      guard
          sizeResult == 0,
          attribute.valueLen > 0,
          attribute.valueLen != UInt.max
      else {
        return nil
      }

      var bytes = Array<UInt8>(
          repeating: 0,
          count: Int(attribute.valueLen)
      )

      let readResult = bytes.withUnsafeMutableBytes { buffer in
        attribute.value = buffer.baseAddress

        return withUnsafeMutablePointer(to: &attribute) { pointer in
          cGetAttributeValue(
              session,
              object,
              UnsafeMutableRawPointer(pointer),
              1
          )
        }
      }

      guard readResult == 0 else {
        return nil
      }

      return bytes
    }

    func labelForObject(
        session: UInt,
        object: UInt
    ) -> String {
      guard let bytes = readAttribute(
          session: session,
          object: object,
          type: ckaLabel
      ) else {
        return ""
      }

      return String(
          bytes: bytes,
          encoding: .utf8
      )?.trimmingCharacters(
          in: .whitespacesAndNewlines
      ) ?? ""
    }

    func idForObject(
        session: UInt,
        object: UInt
    ) -> String {
      guard let bytes = readAttribute(
          session: session,
          object: object,
          type: ckaId
      ) else {
        return ""
      }

      return bytes
      .map { String(format: "%02X", $0) }
      .joined()
    }

    // ------------------------------------------------------------
    // Recherche d'une classe d'objets
    // ------------------------------------------------------------

    func findObjects(
        session: UInt,
        objectClass: UInt,
        className: String
    ) -> [[String: Any]] {
      var classValue = objectClass

      var attribute = CKAttribute(
          type: ckaClass,
          value: nil,
          valueLen: UInt(
              MemoryLayout<UInt>.size
          )
      )

      let initResult = withUnsafeMutablePointer(
          to: &classValue
      ) { classPointer in
        attribute.value =
            UnsafeMutableRawPointer(classPointer)

        return withUnsafeMutablePointer(
            to: &attribute
        ) { attributePointer in
          cFindObjectsInit(
              session,
              UnsafeMutableRawPointer(
                  attributePointer
              ),
              1
          )
        }
      }

      guard initResult == 0 else {
        return [[
          "class": className,
          "errorStep": "C_FindObjectsInit",
          "returnCode": initResult,
        ]]
      }

      defer {
        _ = cFindObjectsFinal(session)
      }

      var result: [[String: Any]] = []

      while true {
        var handles = Array<UInt>(
            repeating: 0,
            count: 16
        )

        var foundCount: UInt = 0

        let findResult = cFindObjects(
            session,
            &handles,
            UInt(handles.count),
            &foundCount
        )

        guard findResult == 0 else {
          result.append([
                          "class": className,
                          "errorStep": "C_FindObjects",
                          "returnCode": findResult,
                        ])
          break
        }

        if foundCount == 0 {
          break
        }

        for index in 0..<Int(foundCount) {
          let objectHandle = handles[index]

          var objectResult: [String: Any] = [
            "class": className,
            "classValue": objectClass,
            "handle": objectHandle,
            "label": labelForObject(
                session: session,
                object: objectHandle
            ),
            "id": idForObject(
                session: session,
                object: objectHandle
            ),
          ]

          if objectClass == ckoCertificate {
            if let certificateBytes = readAttribute(
                session: session,
                object: objectHandle,
                type: ckaValue
            ) {
              objectResult["certificateBase64"] =
                  Data(certificateBytes).base64EncodedString()

              objectResult["certificateLength"] =
                  certificateBytes.count
            }
          }

          result.append(objectResult)
        }
      }

      return result
    }

    // ------------------------------------------------------------
    // Initialisation
    // ------------------------------------------------------------

    let initializeReturnCode = cInitialize(nil)

    guard initializeReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Initialize",
        "returnCode": initializeReturnCode,
      ]
    }

    defer {
      _ = cFinalize(nil)
    }

    // ------------------------------------------------------------
    // Recherche du token
    // ------------------------------------------------------------

    var tokenSlotCount: UInt = 0

    let slotCountReturnCode = cGetSlotList(
        1,
        nil,
        &tokenSlotCount
    )

    guard
        slotCountReturnCode == 0,
        tokenSlotCount > 0
    else {
      return [
        "success": false,
        "step": "C_GetSlotList",
        "returnCode": slotCountReturnCode,
        "tokenSlotCount": tokenSlotCount,
      ]
    }

    var tokenSlotIds = Array<UInt>(
        repeating: 0,
        count: Int(tokenSlotCount)
    )

    let slotListReturnCode = cGetSlotList(
        1,
        &tokenSlotIds,
        &tokenSlotCount
    )

    guard slotListReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_GetSlotList(ids)",
        "returnCode": slotListReturnCode,
      ]
    }

    let tokenSlotId = tokenSlotIds[0]

    // ------------------------------------------------------------
    // Session
    // ------------------------------------------------------------

    var sessionHandle: UInt = 0

    let openSessionReturnCode = cOpenSession(
        tokenSlotId,
        ckfSerialSession,
        nil,
        nil,
        &sessionHandle
    )

    guard openSessionReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_OpenSession",
        "returnCode": openSessionReturnCode,
      ]
    }

    defer {
      _ = cCloseSession(sessionHandle)
    }

    // ------------------------------------------------------------
    // Authentification utilisateur
    // ------------------------------------------------------------

    var pinBytes = Array(pin.utf8)

    let loginReturnCode =
        pinBytes.withUnsafeMutableBufferPointer { buffer in
          cLogin(
              sessionHandle,
              ckuUser,
              buffer.baseAddress,
              UInt(buffer.count)
          )
        }

    guard loginReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Login",
        "loginReturnCode": loginReturnCode,
      ]
    }

    defer {
      _ = cLogout(sessionHandle)
    }

    // ------------------------------------------------------------
    // Inventaire des objets
    // ------------------------------------------------------------

    let privateKeys = findObjects(
        session: sessionHandle,
        objectClass: ckoPrivateKey,
        className: "CKO_PRIVATE_KEY"
    )

    let certificates = findObjects(
        session: sessionHandle,
        objectClass: ckoCertificate,
        className: "CKO_CERTIFICATE"
    )

    return [
      "success": true,
      "step": "C_FindObjects",
      "privateKeyCount": privateKeys.count,
      "certificateCount": certificates.count,
      "privateKeys": privateKeys,
      "certificates": certificates,
    ]
  }

  private static func getPkcs11SigningCertificate(
      pin: String
  ) -> [String: Any] {
    let libraryPath = "/usr/local/lib/libcps3_pkcs11_osx.dylib"

    let ckuUser: UInt = 1
    let ckfSerialSession: UInt = 0x00000004

    let ckoCertificate: UInt = 1

    let ckaClass: UInt = 0
    let ckaLabel: UInt = 3
    let ckaId: UInt = 0x102
    let ckaValue: UInt = 0x11

    let expectedLabel = "Certificat de Signature CPS"

    struct CKAttribute {
      var type: UInt
      var value: UnsafeMutableRawPointer?
      var valueLen: UInt
    }

    guard let library = dlopen(libraryPath, RTLD_NOW) else {
      let error = dlerror().map {
        String(cString: $0)
      } ?? "Erreur inconnue"

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
        let initializeSymbol = dlsym(library, "C_Initialize"),
        let finalizeSymbol = dlsym(library, "C_Finalize"),
        let getSlotListSymbol = dlsym(library, "C_GetSlotList"),
        let openSessionSymbol = dlsym(library, "C_OpenSession"),
        let loginSymbol = dlsym(library, "C_Login"),
        let logoutSymbol = dlsym(library, "C_Logout"),
        let closeSessionSymbol = dlsym(library, "C_CloseSession"),
        let findObjectsInitSymbol = dlsym(library, "C_FindObjectsInit"),
        let findObjectsSymbol = dlsym(library, "C_FindObjects"),
        let findObjectsFinalSymbol = dlsym(library, "C_FindObjectsFinal"),
        let getAttributeValueSymbol = dlsym(library, "C_GetAttributeValue")
    else {
      return [
        "success": false,
        "step": "dlsym",
        "error": "Un ou plusieurs symboles PKCS#11 sont introuvables",
      ]
    }

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

    typealias COpenSession = @convention(c) (
        UInt,
        UInt,
        UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

    typealias CLogin = @convention(c) (
        UInt,
        UInt,
        UnsafeMutablePointer<UInt8>?,
        UInt
    ) -> UInt

    typealias CLogout = @convention(c) (
        UInt
    ) -> UInt

    typealias CCloseSession = @convention(c) (
        UInt
    ) -> UInt

    typealias CFindObjectsInit = @convention(c) (
        UInt,
        UnsafeMutableRawPointer?,
        UInt
    ) -> UInt

    typealias CFindObjects = @convention(c) (
        UInt,
        UnsafeMutablePointer<UInt>?,
        UInt,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

    typealias CFindObjectsFinal = @convention(c) (
        UInt
    ) -> UInt

    typealias CGetAttributeValue = @convention(c) (
        UInt,
        UInt,
        UnsafeMutableRawPointer?,
        UInt
    ) -> UInt

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

    let cOpenSession = unsafeBitCast(
        openSessionSymbol,
        to: COpenSession.self
    )

    let cLogin = unsafeBitCast(
        loginSymbol,
        to: CLogin.self
    )

    let cLogout = unsafeBitCast(
        logoutSymbol,
        to: CLogout.self
    )

    let cCloseSession = unsafeBitCast(
        closeSessionSymbol,
        to: CCloseSession.self
    )

    let cFindObjectsInit = unsafeBitCast(
        findObjectsInitSymbol,
        to: CFindObjectsInit.self
    )

    let cFindObjects = unsafeBitCast(
        findObjectsSymbol,
        to: CFindObjects.self
    )

    let cFindObjectsFinal = unsafeBitCast(
        findObjectsFinalSymbol,
        to: CFindObjectsFinal.self
    )

    let cGetAttributeValue = unsafeBitCast(
        getAttributeValueSymbol,
        to: CGetAttributeValue.self
    )

    func readAttribute(
        session: UInt,
        object: UInt,
        type: UInt
    ) -> [UInt8]? {
      var attribute = CKAttribute(
          type: type,
          value: nil,
          valueLen: 0
      )

      let sizeResult =
          withUnsafeMutablePointer(to: &attribute) { pointer in
            cGetAttributeValue(
                session,
                object,
                UnsafeMutableRawPointer(pointer),
                1
            )
          }

      guard
          sizeResult == 0,
          attribute.valueLen > 0,
          attribute.valueLen != UInt.max
      else {
        return nil
      }

      var bytes = Array<UInt8>(
          repeating: 0,
          count: Int(attribute.valueLen)
      )

      let readResult = bytes.withUnsafeMutableBytes { buffer in
        attribute.value = buffer.baseAddress

        return withUnsafeMutablePointer(to: &attribute) { pointer in
          cGetAttributeValue(
              session,
              object,
              UnsafeMutableRawPointer(pointer),
              1
          )
        }
      }

      guard readResult == 0 else {
        return nil
      }

      return bytes
    }

    func readStringAttribute(
        session: UInt,
        object: UInt,
        type: UInt
    ) -> String {
      guard let bytes = readAttribute(
          session: session,
          object: object,
          type: type
      ) else {
        return ""
      }

      return String(
          bytes: bytes,
          encoding: .utf8
      )?.trimmingCharacters(
          in: .whitespacesAndNewlines
      ) ?? ""
    }

    let initializeReturnCode = cInitialize(nil)

    guard initializeReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Initialize",
        "returnCode": initializeReturnCode,
      ]
    }

    defer {
      _ = cFinalize(nil)
    }

    var tokenSlotCount: UInt = 0

    let slotCountReturnCode = cGetSlotList(
        1,
        nil,
        &tokenSlotCount
    )

    guard
        slotCountReturnCode == 0,
        tokenSlotCount > 0
    else {
      return [
        "success": false,
        "step": "C_GetSlotList",
        "returnCode": slotCountReturnCode,
      ]
    }

    var tokenSlotIds = Array<UInt>(
        repeating: 0,
        count: Int(tokenSlotCount)
    )

    let slotListReturnCode = cGetSlotList(
        1,
        &tokenSlotIds,
        &tokenSlotCount
    )

    guard slotListReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_GetSlotList(ids)",
        "returnCode": slotListReturnCode,
      ]
    }

    let tokenSlotId = tokenSlotIds[0]

    var sessionHandle: UInt = 0

    let openSessionReturnCode = cOpenSession(
        tokenSlotId,
        ckfSerialSession,
        nil,
        nil,
        &sessionHandle
    )

    guard openSessionReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_OpenSession",
        "returnCode": openSessionReturnCode,
      ]
    }

    defer {
      _ = cCloseSession(sessionHandle)
    }

    var pinBytes = Array(pin.utf8)

    let loginReturnCode =
        pinBytes.withUnsafeMutableBufferPointer { buffer in
          cLogin(
              sessionHandle,
              ckuUser,
              buffer.baseAddress,
              UInt(buffer.count)
          )
        }

    guard loginReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Login",
        "returnCode": loginReturnCode,
      ]
    }

    defer {
      _ = cLogout(sessionHandle)
    }

    var classValue = ckoCertificate

    var classAttribute = CKAttribute(
        type: ckaClass,
        value: nil,
        valueLen: UInt(MemoryLayout<UInt>.size)
    )

    let findInitReturnCode =
        withUnsafeMutablePointer(to: &classValue) { classPointer in
          classAttribute.value =
              UnsafeMutableRawPointer(classPointer)

          return withUnsafeMutablePointer(
              to: &classAttribute
          ) { attributePointer in
            cFindObjectsInit(
                sessionHandle,
                UnsafeMutableRawPointer(attributePointer),
                1
            )
          }
        }

    guard findInitReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_FindObjectsInit",
        "returnCode": findInitReturnCode,
      ]
    }

    defer {
      _ = cFindObjectsFinal(sessionHandle)
    }

    var handles = Array<UInt>(
        repeating: 0,
        count: 16
    )

    var foundCount: UInt = 0

    let findReturnCode = cFindObjects(
        sessionHandle,
        &handles,
        UInt(handles.count),
        &foundCount
    )

    guard findReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_FindObjects",
        "returnCode": findReturnCode,
      ]
    }

    for index in 0..<Int(foundCount) {
      let objectHandle = handles[index]

      let label = readStringAttribute(
          session: sessionHandle,
          object: objectHandle,
          type: ckaLabel
      )

      guard label == expectedLabel else {
        continue
      }

      guard let certificateBytes = readAttribute(
          session: sessionHandle,
          object: objectHandle,
          type: ckaValue
      ) else {
        return [
          "success": false,
          "step": "C_GetAttributeValue(CKA_VALUE)",
          "error": "Certificat de signature illisible",
        ]
      }

      let idBytes = readAttribute(
          session: sessionHandle,
          object: objectHandle,
          type: ckaId
      ) ?? []

      let certificateId = idBytes
      .map { String(format: "%02X", $0) }
      .joined()

      let certificateData = Data(certificateBytes)

      return [
        "success": true,
        "step": "C_GetAttributeValue(CKA_VALUE)",
        "label": label,
        "id": certificateId,
        "certificateBase64": certificateData.base64EncodedString(),
        "certificateLength": certificateBytes.count,
      ]
    }

    return [
      "success": false,
      "step": "C_FindObjects",
      "error": "Certificat de Signature CPS introuvable",
    ]
  }

  private static func signPkcs11Message(
      pin: String,
      message: String
  ) -> [String: Any] {
    let libraryPath = "/usr/local/lib/libcps3_pkcs11_osx.dylib"

    let ckuUser: UInt = 1
    let ckfSerialSession: UInt = 0x00000004

    let ckoPrivateKey: UInt = 3

    let ckaClass: UInt = 0
    let ckaLabel: UInt = 3

    let ckmSha256RsaPkcs: UInt = 0x40

    let expectedLabel = "CPS_PRIV_SIG"

    struct CKAttribute {
      var type: UInt
      var value: UnsafeMutableRawPointer?
      var valueLen: UInt
    }

    struct CKMechanism {
      var mechanism: UInt
      var parameter: UnsafeMutableRawPointer?
      var parameterLen: UInt
    }

    guard let library = dlopen(libraryPath, RTLD_NOW) else {
      let error = dlerror().map {
        String(cString: $0)
      } ?? "Erreur inconnue"

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
        let initializeSymbol = dlsym(library, "C_Initialize"),
        let finalizeSymbol = dlsym(library, "C_Finalize"),
        let getSlotListSymbol = dlsym(library, "C_GetSlotList"),
        let openSessionSymbol = dlsym(library, "C_OpenSession"),
        let loginSymbol = dlsym(library, "C_Login"),
        let logoutSymbol = dlsym(library, "C_Logout"),
        let closeSessionSymbol = dlsym(library, "C_CloseSession"),
        let findObjectsInitSymbol = dlsym(library, "C_FindObjectsInit"),
        let findObjectsSymbol = dlsym(library, "C_FindObjects"),
        let findObjectsFinalSymbol = dlsym(library, "C_FindObjectsFinal"),
        let getAttributeValueSymbol = dlsym(library, "C_GetAttributeValue"),
        let signInitSymbol = dlsym(library, "C_SignInit"),
        let signSymbol = dlsym(library, "C_Sign")
    else {
      return [
        "success": false,
        "step": "dlsym",
        "error": "Un ou plusieurs symboles PKCS#11 sont introuvables",
      ]
    }

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

    typealias COpenSession = @convention(c) (
        UInt,
        UInt,
        UnsafeMutableRawPointer?,
        UnsafeMutableRawPointer?,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

    typealias CLogin = @convention(c) (
        UInt,
        UInt,
        UnsafeMutablePointer<UInt8>?,
        UInt
    ) -> UInt

    typealias CLogout = @convention(c) (
        UInt
    ) -> UInt

    typealias CCloseSession = @convention(c) (
        UInt
    ) -> UInt

    typealias CFindObjectsInit = @convention(c) (
        UInt,
        UnsafeMutableRawPointer?,
        UInt
    ) -> UInt

    typealias CFindObjects = @convention(c) (
        UInt,
        UnsafeMutablePointer<UInt>?,
        UInt,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

    typealias CFindObjectsFinal = @convention(c) (
        UInt
    ) -> UInt

    typealias CGetAttributeValue = @convention(c) (
        UInt,
        UInt,
        UnsafeMutableRawPointer?,
        UInt
    ) -> UInt

    typealias CSignInit = @convention(c) (
        UInt,
        UnsafeMutableRawPointer?,
        UInt
    ) -> UInt

    typealias CSign = @convention(c) (
        UInt,
        UnsafeMutablePointer<UInt8>?,
        UInt,
        UnsafeMutablePointer<UInt8>?,
        UnsafeMutablePointer<UInt>?
    ) -> UInt

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

    let cOpenSession = unsafeBitCast(
        openSessionSymbol,
        to: COpenSession.self
    )

    let cLogin = unsafeBitCast(
        loginSymbol,
        to: CLogin.self
    )

    let cLogout = unsafeBitCast(
        logoutSymbol,
        to: CLogout.self
    )

    let cCloseSession = unsafeBitCast(
        closeSessionSymbol,
        to: CCloseSession.self
    )

    let cFindObjectsInit = unsafeBitCast(
        findObjectsInitSymbol,
        to: CFindObjectsInit.self
    )

    let cFindObjects = unsafeBitCast(
        findObjectsSymbol,
        to: CFindObjects.self
    )

    let cFindObjectsFinal = unsafeBitCast(
        findObjectsFinalSymbol,
        to: CFindObjectsFinal.self
    )

    let cGetAttributeValue = unsafeBitCast(
        getAttributeValueSymbol,
        to: CGetAttributeValue.self
    )

    let cSignInit = unsafeBitCast(
        signInitSymbol,
        to: CSignInit.self
    )

    let cSign = unsafeBitCast(
        signSymbol,
        to: CSign.self
    )

    func readStringAttribute(
        session: UInt,
        object: UInt,
        type: UInt
    ) -> String {
      var attribute = CKAttribute(
          type: type,
          value: nil,
          valueLen: 0
      )

      let sizeResult =
          withUnsafeMutablePointer(to: &attribute) { pointer in
            cGetAttributeValue(
                session,
                object,
                UnsafeMutableRawPointer(pointer),
                1
            )
          }

      guard
          sizeResult == 0,
          attribute.valueLen > 0,
          attribute.valueLen != UInt.max
      else {
        return ""
      }

      var bytes = Array<UInt8>(
          repeating: 0,
          count: Int(attribute.valueLen)
      )

      let readResult = bytes.withUnsafeMutableBytes { buffer in
        attribute.value = buffer.baseAddress

        return withUnsafeMutablePointer(to: &attribute) { pointer in
          cGetAttributeValue(
              session,
              object,
              UnsafeMutableRawPointer(pointer),
              1
          )
        }
      }

      guard readResult == 0 else {
        return ""
      }

      return String(
          bytes: bytes,
          encoding: .utf8
      )?.trimmingCharacters(
          in: .whitespacesAndNewlines
      ) ?? ""
    }

    let initializeReturnCode = cInitialize(nil)

    guard initializeReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Initialize",
        "returnCode": initializeReturnCode,
      ]
    }

    defer {
      _ = cFinalize(nil)
    }

    var tokenSlotCount: UInt = 0

    let slotCountReturnCode = cGetSlotList(
        1,
        nil,
        &tokenSlotCount
    )

    guard
        slotCountReturnCode == 0,
        tokenSlotCount > 0
    else {
      return [
        "success": false,
        "step": "C_GetSlotList",
        "returnCode": slotCountReturnCode,
      ]
    }

    var tokenSlotIds = Array<UInt>(
        repeating: 0,
        count: Int(tokenSlotCount)
    )

    let slotListReturnCode = cGetSlotList(
        1,
        &tokenSlotIds,
        &tokenSlotCount
    )

    guard slotListReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_GetSlotList(ids)",
        "returnCode": slotListReturnCode,
      ]
    }

    let tokenSlotId = tokenSlotIds[0]

    var sessionHandle: UInt = 0

    let openSessionReturnCode = cOpenSession(
        tokenSlotId,
        ckfSerialSession,
        nil,
        nil,
        &sessionHandle
    )

    guard openSessionReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_OpenSession",
        "returnCode": openSessionReturnCode,
      ]
    }

    defer {
      _ = cCloseSession(sessionHandle)
    }

    var pinBytes = Array(pin.utf8)

    let loginReturnCode =
        pinBytes.withUnsafeMutableBufferPointer { buffer in
          cLogin(
              sessionHandle,
              ckuUser,
              buffer.baseAddress,
              UInt(buffer.count)
          )
        }

    guard loginReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Login",
        "returnCode": loginReturnCode,
      ]
    }

    defer {
      _ = cLogout(sessionHandle)
    }

    var classValue = ckoPrivateKey

    var classAttribute = CKAttribute(
        type: ckaClass,
        value: nil,
        valueLen: UInt(MemoryLayout<UInt>.size)
    )

    let findInitReturnCode =
        withUnsafeMutablePointer(to: &classValue) { classPointer in
          classAttribute.value =
              UnsafeMutableRawPointer(classPointer)

          return withUnsafeMutablePointer(
              to: &classAttribute
          ) { attributePointer in
            cFindObjectsInit(
                sessionHandle,
                UnsafeMutableRawPointer(attributePointer),
                1
            )
          }
        }

    guard findInitReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_FindObjectsInit",
        "returnCode": findInitReturnCode,
      ]
    }

    defer {
      _ = cFindObjectsFinal(sessionHandle)
    }

    var handles = Array<UInt>(
        repeating: 0,
        count: 16
    )

    var foundCount: UInt = 0

    let findReturnCode = cFindObjects(
        sessionHandle,
        &handles,
        UInt(handles.count),
        &foundCount
    )

    guard findReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_FindObjects",
        "returnCode": findReturnCode,
      ]
    }

    var signingKeyHandle: UInt?

    for index in 0..<Int(foundCount) {
      let objectHandle = handles[index]

      let label = readStringAttribute(
          session: sessionHandle,
          object: objectHandle,
          type: ckaLabel
      )

      if label == expectedLabel {
        signingKeyHandle = objectHandle
        break
      }
    }

    guard let keyHandle = signingKeyHandle else {
      return [
        "success": false,
        "step": "C_FindObjects",
        "error": "Clé privée CPS_PRIV_SIG introuvable",
      ]
    }

    var mechanism = CKMechanism(
        mechanism: ckmSha256RsaPkcs,
        parameter: nil,
        parameterLen: 0
    )

    let signInitReturnCode =
        withUnsafeMutablePointer(to: &mechanism) { pointer in
          cSignInit(
              sessionHandle,
              UnsafeMutableRawPointer(pointer),
              keyHandle
          )
        }

    guard signInitReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_SignInit",
        "returnCode": signInitReturnCode,
      ]
    }

    var messageBytes = Array(message.utf8)

    var signatureLength: UInt = 0

    let signatureSizeReturnCode =
        messageBytes.withUnsafeMutableBufferPointer { buffer in
          cSign(
              sessionHandle,
              buffer.baseAddress,
              UInt(buffer.count),
              nil,
              &signatureLength
          )
        }

    guard signatureSizeReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Sign(size)",
        "returnCode": signatureSizeReturnCode,
      ]
    }

    var signatureBytes = Array<UInt8>(
        repeating: 0,
        count: Int(signatureLength)
    )

    let signReturnCode =
        messageBytes.withUnsafeMutableBufferPointer { messageBuffer in
          signatureBytes.withUnsafeMutableBufferPointer { signatureBuffer in
            cSign(
                sessionHandle,
                messageBuffer.baseAddress,
                UInt(messageBuffer.count),
                signatureBuffer.baseAddress,
                &signatureLength
            )
          }
        }

    guard signReturnCode == 0 else {
      return [
        "success": false,
        "step": "C_Sign",
        "returnCode": signReturnCode,
      ]
    }

    if signatureBytes.count > Int(signatureLength) {
      signatureBytes.removeLast(
          signatureBytes.count - Int(signatureLength)
      )
    }

    let signatureBase64 =
        Data(signatureBytes).base64EncodedString()

    return [
      "success": true,
      "step": "C_Sign",
      "keyLabel": expectedLabel,
      "keyHandle": keyHandle,
      "mechanism": ckmSha256RsaPkcs,
      "signatureLength": signatureLength,
      "signatureBase64": signatureBase64,
    ]
  }

  private static func verifyInsiPsSignature(
      canonicalSignedInfo: String,
      signatureBase64: String,
      certificateBase64: String
  ) -> [String: Any] {
    guard
        let certificateData = Data(
            base64Encoded: certificateBase64
        )
    else {
      return [
        "success": false,
        "step": "decodeCertificate",
        "error": "Certificat Base64 invalide",
      ]
    }

    guard
        let certificate = SecCertificateCreateWithData(
            nil,
            certificateData as CFData
        )
    else {
      return [
        "success": false,
        "step": "SecCertificateCreateWithData",
        "error": "Certificat X.509 invalide",
      ]
    }

    guard
        let publicKey = SecCertificateCopyKey(
            certificate
        )
    else {
      return [
        "success": false,
        "step": "SecCertificateCopyKey",
        "error": "Clé publique introuvable",
      ]
    }

    guard
        let signatureData = Data(
            base64Encoded: signatureBase64
        )
    else {
      return [
        "success": false,
        "step": "decodeSignature",
        "error": "Signature Base64 invalide",
      ]
    }

    guard
        let messageData = canonicalSignedInfo.data(
            using: .utf8
        )
    else {
      return [
        "success": false,
        "step": "UTF8",
        "error": "SignedInfo UTF-8 invalide",
      ]
    }

    let algorithm =
        SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA256

    guard SecKeyIsAlgorithmSupported(
        publicKey,
        .verify,
        algorithm
    ) else {
      return [
        "success": false,
        "step": "SecKeyIsAlgorithmSupported",
        "error": "RSA-SHA256 non supporté par la clé publique",
      ]
    }

    var error: Unmanaged<CFError>?

    let verified = SecKeyVerifySignature(
        publicKey,
        algorithm,
        messageData as CFData,
        signatureData as CFData,
        &error
    )

    if !verified {
      let errorDescription =
          error?.takeRetainedValue().localizedDescription
              ?? "Signature invalide"

      return [
        "success": false,
        "step": "SecKeyVerifySignature",
        "verified": false,
        "error": errorDescription,
      ]
    }

    return [
      "success": true,
      "step": "SecKeyVerifySignature",
      "verified": true,
      "signatureLength": signatureData.count,
      "certificateLength": certificateData.count,
    ]
  }
}