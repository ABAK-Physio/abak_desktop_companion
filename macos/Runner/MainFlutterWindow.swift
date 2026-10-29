import Cocoa
import FlutterMacOS
import Darwin
import Security
import CryptoKit

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let arguments = Array(CommandLine.arguments.dropFirst())
    let bundleResources = arguments.contains("--abak-bundle-resources")
    let coordinated = arguments.contains(where: { $0.hasPrefix("--abak-coordinated-phase=") })
    if coordinated {
      guard arguments.contains("--abak-maintenance"), arguments.contains("--abak-maintenance-authorize"),
            Bundle.main.object(forInfoDictionaryKey: "ABAKCoordinatedRecipeOnly") as? Bool == true,
            Bundle.main.object(forInfoDictionaryKey: "ABAKMaintenanceRecipeOnly") as? Bool == true,
            Bundle.main.bundleIdentifier?.hasPrefix("fr.abakphysio.maintenance.recipe.") == true else { exit(78) }
    }
    if bundleResources {
      guard arguments.contains("--abak-maintenance"),
            arguments.contains("--abak-maintenance-authorize"),
            Bundle.main.object(forInfoDictionaryKey: "ABAKBundleResourcesRecipeOnly") as? Bool == true,
            Bundle.main.object(forInfoDictionaryKey: "ABAKMaintenanceRecipeOnly") as? Bool == true,
            Bundle.main.bundleIdentifier?.hasPrefix("fr.abakphysio.maintenance.recipe.") == true else { exit(78) }
    }
    // A recipe copy must never fall through into normal startup when opened
    // from Finder or without the complete explicit synthetic-maintenance flags.
    if Bundle.main.object(forInfoDictionaryKey: "ABAKMaintenanceRecipeOnly") as? Bool == true {
      guard arguments.contains("--abak-maintenance"),
            arguments.contains(where: { $0.hasPrefix("--abak-maintenance-root=") }) else {
        fputs("Copie de recette : lancement métier interdit.\n", stderr)
        exit(78)
      }
    }
    // Forward explicit launch options; no CPS/INSi call is made here.
    let project = FlutterDartProject()
    project.dartEntrypointArguments = arguments
    let flutterViewController = FlutterViewController(project: project)
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    AbakDocumentControlsBridge.shared.register(with: flutterViewController.engine.binaryMessenger)
    if arguments.contains("--abak-maintenance") {
      AbakMaintenanceAccess.shared.register(with: flutterViewController.engine.binaryMessenger)
      if bundleResources {
        let channel = FlutterMethodChannel(name: "abak/bundle_resources_recipe", binaryMessenger: flutterViewController.engine.binaryMessenger)
        channel.setMethodCallHandler { call, result in
          if call.method == "context" {
            result(["identity": Bundle.main.bundleIdentifier!,
                    "generation": Bundle.main.bundleURL.deletingLastPathComponent().path])
          } else { result(FlutterMethodNotImplemented) }
        }
      }
      // Test-only entry point, with a fresh signed identity and restricted rights.
      // Never expose preference restoration or the directory bridge in normal maintenance.
      if Bundle.main.object(forInfoDictionaryKey: "ABAKPreferencesRecipeOnly") as? Bool == true || coordinated {
        guard Bundle.main.bundleIdentifier?.hasPrefix("fr.abakphysio.maintenance.recipe.") == true,
              Bundle.main.object(forInfoDictionaryKey: "ABAKMaintenanceRecipeOnly") as? Bool == true else {
          exit(78)
        }
        AbakDirectoryAccessBridge.shared.register(with: flutterViewController.engine.binaryMessenger)
        AbakPreferencesRecipe.register(with: flutterViewController.engine.binaryMessenger)
      }
      super.awakeFromNib()
      return
    }
    AbakDirectoryAccessBridge.shared.register(
        with: flutterViewController.engine.binaryMessenger
    )

    let consultationDisplay = FlutterMethodChannel(name: "abak/dmp_consultation_display", binaryMessenger: flutterViewController.engine.binaryMessenger)
    consultationDisplay.setMethodCallHandler { call, result in
      guard call.method == "pdf", let args = call.arguments as? [String: Any],
            let bytes = args["bytes"] as? FlutterStandardTypedData,
            bytes.data.count <= 16 * 1024 * 1024, let mime = args["mime"] as? String else {
        result(FlutterError(code: "DISPLAY", message: "Contenu invalide", details: nil)); return
      }
      // In-memory AppKit rendering only. No file, browser, external URL or print dialog.
      if mime == "application/rtf" || mime == "text/rtf" {
        guard let attributed = NSAttributedString(rtf: bytes.data, documentAttributes: nil), attributed.length <= 500000 else {
          result(FlutterError(code: "DISPLAY", message: "RTF illisible", details: nil)); return
        }
        let text = NSTextView(frame: NSRect(x: 0, y: 0, width: 600, height: 800))
        text.textStorage?.setAttributedString(attributed)
        text.textContainer?.containerSize = NSSize(width: 580, height: 100000)
        text.textContainer?.widthTracksTextView = false
        guard let manager = text.layoutManager, let container = text.textContainer else { result(FlutterError(code: "DISPLAY", message: "RTF illisible", details: nil)); return }
        manager.ensureLayout(for: container)
        let height = manager.usedRect(for: container).height + 40
        guard height > 0, height < 30000 else { result(FlutterError(code: "DISPLAY", message: "RTF trop volumineux", details: nil)); return }
        text.setFrameSize(NSSize(width: 600, height: height))
        result(FlutterStandardTypedData(bytes: text.dataWithPDF(inside: text.bounds)))
      } else if mime == "image/tiff" {
        let reps = NSBitmapImageRep.imageReps(with: bytes.data)
        guard !reps.isEmpty, reps.count <= 40, reps.allSatisfy({ $0.pixelsWide > 0 && $0.pixelsHigh > 0 && Double($0.pixelsWide)*Double($0.pixelsHigh) <= 20000000 }) else { result(FlutterError(code: "DISPLAY", message: "TIFF illisible", details: nil)); return }
        let heights = reps.map { 600 * Double($0.pixelsHigh) / Double($0.pixelsWide) }
        let height = heights.reduce(0,+)
        guard height < 30000 else { result(FlutterError(code: "DISPLAY", message: "TIFF trop volumineux", details: nil)); return }
        let view = NSView(frame:NSRect(x:0,y:0,width:600,height:height))
        var y = height
        for (index, rep) in reps.enumerated() {
          y -= heights[index]
          let image = NSImage(size:NSSize(width:rep.pixelsWide,height:rep.pixelsHigh)); image.addRepresentation(rep)
          let imageView=NSImageView(frame:NSRect(x:0,y:y,width:600,height:heights[index])); imageView.image=image; imageView.imageScaling = .scaleProportionallyUpOrDown; view.addSubview(imageView)
        }
        result(FlutterStandardTypedData(bytes:view.dataWithPDF(inside:view.bounds)))
      } else { result(FlutterError(code:"DISPLAY",message:"Format non pris en charge",details:nil)) }
    }

    WebPsBrowserBridge.shared.register(flutterViewController.engine.binaryMessenger)

    let dmpChannel = FlutterMethodChannel(
        name: "abak_dmp_fr",
        binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    dmpChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "readCpsProfile", "testCpsSignature", "signDmpLotLocal", "prepareDmpLotLocal":
        guard let arguments = call.arguments as? [String: Any],
              let pin = arguments["pin"] as? String,
              !pin.isEmpty, pin.utf8.count <= 16,
              pin.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }) else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Saisissez le PIN de la CPS", details: nil))
          return
        }
        if call.method == "testCpsSignature" || call.method == "signDmpLotLocal" || call.method == "prepareDmpLotLocal" {
          guard let expectedId = arguments["expectedNationalId"] as? String,
                !expectedId.isEmpty else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Relisez la CPS avant le test", details: nil))
            return
          }
          if call.method == "prepareDmpLotLocal" {
            result(Self.readCpsProfile(pin: pin, testFor: expectedId, readSigningMaterial: true))
          } else if call.method == "signDmpLotLocal" {
            guard let signedInfo = arguments["signedInfo"] as? String,
                  let certificate = arguments["certificateBase64"] as? String,
                  signedInfo.utf8.count <= 32768, !signedInfo.isEmpty, !certificate.isEmpty else {
              result(FlutterError(code: "INVALID_ARGUMENTS", message: "Lot local incomplet", details: nil))
              return
            }
            result(Self.readCpsProfile(pin: pin, testFor: expectedId,
                                      dmpSignedInfo: signedInfo, expectedCertificate: certificate))
          } else {
            result(Self.readCpsProfile(pin: pin, testFor: expectedId))
          }
        } else {
          result(Self.readCpsProfile(pin: pin))
        }

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

        // Preserve the INSi channel contract, but never guess or retain a PIN.
        guard let pin = (arguments["pin"] as? String) ?? Self.requestCpsPin() else {
          result(FlutterError(code: "CPS_CANCELLED", message: "Signature annulée", details: nil))
          return
        }
        let signatureResult = Self.signPkcs11Message(
            pin: pin,
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

  private static func requestCpsPin() -> String? {
    let alert = NSAlert()
    alert.messageText = "Signature INSi avec votre CPS"
    alert.informativeText = "Saisissez votre PIN. Une seule tentative sera effectuée."
    alert.addButton(withTitle: "Signer")
    alert.addButton(withTitle: "Annuler")
    let field = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 240, height: 24))
    alert.accessoryView = field
    alert.window.initialFirstResponder = field
    let response = alert.runModal()
    let pin = field.stringValue
    field.stringValue = ""
    guard response == .alertFirstButtonReturn, !pin.isEmpty else { return nil }
    return pin
  }

  private static func readCpsProfile(pin: String, testFor expectedId: String? = nil, dmpSignedInfo: String? = nil, expectedCertificate: String? = nil, readSigningMaterial: Bool = false) -> [String: Any] {
    let libraryPath = "/usr/local/lib/libcps3_pkcs11_osx.dylib"

    // PKCS#11
    let ckuUser: UInt = 1
    let ckfSerialSession: UInt = 0x00000004


    let ckaClass: UInt = 0
    let ckaLabel: UInt = 3
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

    var readFailure: [String: Any]?

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
          attribute.valueLen <= 65536
      else {
        readFailure = ["success": false, "step": "C_GetAttributeValue(size)", "returnCode": sizeResult]
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
        readFailure = ["success": false, "step": "C_GetAttributeValue", "returnCode": readResult]
        return nil
      }

      guard attribute.valueLen <= UInt(bytes.count) else { return nil }
      return Array(bytes.prefix(Int(attribute.valueLen)))
    }

    // ANS CPS3 business data: search each CKO_DATA by its exact label.
    func readObject(session: UInt, label: String) -> [UInt8]? {
      var objectClass: UInt = 0
      var token: UInt8 = 1
      var isPrivate: UInt8 = label.hasPrefix("CPS_ACTIVITY_") ? 1 : 0
      var labelBytes = Array(label.utf8)
      let initCode = withUnsafeMutablePointer(to: &objectClass) { cls in
        withUnsafeMutablePointer(to: &token) { tok in
          withUnsafeMutablePointer(to: &isPrivate) { priv in
            labelBytes.withUnsafeMutableBytes { bytes in
              var attributes = [
                CKAttribute(type: ckaClass, value: UnsafeMutableRawPointer(cls), valueLen: UInt(MemoryLayout<UInt>.size)),
                CKAttribute(type: 1, value: UnsafeMutableRawPointer(tok), valueLen: 1),
                CKAttribute(type: 2, value: UnsafeMutableRawPointer(priv), valueLen: 1),
                CKAttribute(type: ckaLabel, value: bytes.baseAddress, valueLen: UInt(bytes.count)),
              ]
              return attributes.withUnsafeMutableBytes { attrs in
                cFindObjectsInit(session, attrs.baseAddress, 4)
              }
            }
          }
        }
      }
      guard initCode == 0 else {
        readFailure = ["success": false, "step": "C_FindObjectsInit", "returnCode": initCode]
        return nil
      }
      var handles: [UInt] = [0, 0]
      var count: UInt = 0
      let findCode = cFindObjects(session, &handles, 2, &count)
      let finalCode = cFindObjectsFinal(session)
      guard findCode == 0 else {
        readFailure = ["success": false, "step": "C_FindObjects", "returnCode": findCode]
        return nil
      }
      guard finalCode == 0 else {
        readFailure = ["success": false, "step": "C_FindObjectsFinal", "returnCode": finalCode]
        return nil
      }
      if count == 0 { return [] }
      guard count == 1 else { return nil }
      return readAttribute(session: session, object: handles[0], type: ckaValue)
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
        tokenSlotCount == 1
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

    guard slotListReturnCode == 0, tokenSlotCount == 1 else {
      return [
        "success": false,
        "step": "C_GetSlotList(ids)",
        "returnCode": slotListReturnCode,
        "tokenSlotCount": tokenSlotCount,
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

    _ = pinBytes.withUnsafeMutableBytes { $0.initializeMemory(as: UInt8.self, repeating: 0) }

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

    var objects: [String: FlutterStandardTypedData] = [:]
    let labels = ["CPS_ID_CARD", "CPS_NAME_PS", "CPS_INFO_PS"] +
        (1...16).map { String(format: "CPS_ACTIVITY_%02d_PS", $0) }
    for label in labels {
      guard let bytes = readObject(session: sessionHandle, label: label) else {
        var failure = readFailure ?? ["success": false, "step": "C_ReadObject"]
        failure["objectLabel"] = label
        return failure
      }
      if !bytes.isEmpty {
        objects[label] = FlutterStandardTypedData(bytes: Data(bytes))
      }
    }
    guard let expectedId = expectedId else {
      return ["success": true, "objects": objects]
    }

    // A single session and login for the entire local test. INSi entry points
    // remain unchanged. Never export or request CKA_VALUE on a private key.
    func failure(_ step: String, _ message: String, _ code: UInt? = nil) -> [String: Any] {
      var value: [String: Any] = ["success": false, "step": step, "error": message]
      if let code = code { value["returnCode"] = code }
      return value
    }
    func findUnique(_ objectClass: UInt, _ label: String) -> UInt? {
      var cls = objectClass
      var name = Array(label.utf8)
      let rv = withUnsafeMutablePointer(to: &cls) { ptr in
        name.withUnsafeMutableBytes { bytes in
          var attrs = [
            CKAttribute(type: ckaClass, value: UnsafeMutableRawPointer(ptr), valueLen: UInt(MemoryLayout<UInt>.size)),
            CKAttribute(type: ckaLabel, value: bytes.baseAddress, valueLen: UInt(bytes.count))
          ]
          return attrs.withUnsafeMutableBytes { cFindObjectsInit(sessionHandle, $0.baseAddress, 2) }
        }
      }
      guard rv == 0 else { return nil }
      var handles: [UInt] = [0, 0]
      var count: UInt = 0
      let found = cFindObjects(sessionHandle, &handles, 2, &count)
      let finished = cFindObjectsFinal(sessionHandle)
      guard found == 0, finished == 0, count == 1 else { return nil }
      return handles[0]
    }
    var certificates: [[String: Any]] = []
    var signingData: Data?
    var signingId: [UInt8]?
    var signingCertificate: SecCertificate?
    for (role, label) in [("signature", "Certificat de Signature CPS"),
                          ("authentification", "Certificat d'Authentification CPS")] {
      guard let handle = findUnique(1, label),
            let bytes = readAttribute(session: sessionHandle, object: handle, type: ckaValue),
            let cert = SecCertificateCreateWithData(nil, Data(bytes) as CFData) else {
        return failure("certificates", "Certificat CPS absent, ambigu ou illisible : " + role)
      }
      var commonName: CFString?
      guard SecCertificateCopyCommonName(cert, &commonName) == errSecSuccess,
            let cn = commonName, (cn as String) == expectedId else {
        return failure("identity", "La carte ou le certificat ne correspond pas à l’identité affichée. Relisez la CPS.")
      }
      let dates = SecCertificateCopyValues(cert,
          [kSecOIDX509V1ValidityNotBefore, kSecOIDX509V1ValidityNotAfter] as CFArray, nil) as? [String: Any]
      func dateValue(_ oid: CFString) -> Date? {
        let item = dates?[oid as String] as? [String: Any]
        guard let value = item?[kSecPropertyKeyValue as String] as? NSNumber else { return nil }
        return Date(timeIntervalSinceReferenceDate: value.doubleValue)
      }
      guard let start = dateValue(kSecOIDX509V1ValidityNotBefore),
            let end = dateValue(kSecOIDX509V1ValidityNotAfter) else {
        return failure("certificates", "Dates du certificat illisibles")
      }
      let data = Data(bytes)
      certificates.append([
        "role": role, "nationalId": expectedId,
        "certificateBase64": data.base64EncodedString(),
        "sha256": SHA256.hash(data: data).map { String(format: "%02X", $0) }.joined(),
        "validFrom": ISO8601DateFormatter().string(from: start),
        "validUntil": ISO8601DateFormatter().string(from: end)
      ])
      guard start <= Date(), Date() <= end else {
        return failure("certificates", "Certificat hors période de validité : " + role)
      }
      if role == "signature" {
        signingData = data
        signingCertificate = cert
        signingId = readAttribute(session: sessionHandle, object: handle, type: 0x102)
      }
    }
    // Explicit local preparation: public certificates only, no C_Sign call.
    if readSigningMaterial {
      return ["success": true, "objects": objects, "certificates": certificates,
              "nationalId": expectedId]
    }
    guard let key = findUnique(3, "CPS_PRIV_SIG"),
          let keyId = readAttribute(session: sessionHandle, object: key, type: 0x102),
          let certId = signingId, !certId.isEmpty, keyId == certId,
          let cert = signingCertificate, let certData = signingData,
          let publicKey = SecCertificateCopyKey(cert) else {
      return failure("keyBinding", "Impossible d’associer la clé de signature au certificat CPS")
    }
    if dmpSignedInfo != nil && certData.base64EncodedString() != expectedCertificate {
      return failure("identity", "Le certificat de la carte a changé depuis la préparation du lot")
    }
    typealias SignInit = @convention(c) (UInt, UnsafeMutableRawPointer?, UInt) -> UInt
    typealias Sign = @convention(c) (UInt, UnsafeMutablePointer<UInt8>?, UInt,
                                    UnsafeMutablePointer<UInt8>?, UnsafeMutablePointer<UInt>?) -> UInt
    guard let initSymbol = dlsym(library, "C_SignInit"), let symbol = dlsym(library, "C_Sign") else {
      return failure("dlsym", "Fonctions de signature absentes")
    }
    let signInit = unsafeBitCast(initSymbol, to: SignInit.self)
    let sign = unsafeBitCast(symbol, to: Sign.self)
    struct Mechanism { var type: UInt; var parameter: UnsafeMutableRawPointer?; var length: UInt }
    // SHA-1 only for the offline reproduction of SEL-MP-037 A6-2.
    // Existing CPS diagnostic and all INSi signing retain SHA-256.
    var mechanism = Mechanism(type: dmpSignedInfo == nil ? 0x40 : 0x06, parameter: nil, length: 0)
    let initialized = withUnsafeMutablePointer(to: &mechanism) {
      signInit(sessionHandle, UnsafeMutableRawPointer($0), key)
    }
    guard initialized == 0 else { return failure("C_SignInit", "Initialisation de signature refusée", initialized) }
    let message = dmpSignedInfo ?? ("ABAK CPS LOCAL SIGNATURE TEST | " + UUID().uuidString)
    var messageBytes = Array(message.utf8)
    var length: UInt = 0
    let sized = messageBytes.withUnsafeMutableBufferPointer {
      sign(sessionHandle, $0.baseAddress, UInt($0.count), nil, &length)
    }
    guard sized == 0, length > 0, length <= 16384 else {
      return failure("C_Sign(size)", "Taille de signature invalide", sized)
    }
    var bytes = [UInt8](repeating: 0, count: Int(length))
    let signed = messageBytes.withUnsafeMutableBufferPointer { msg in
      bytes.withUnsafeMutableBufferPointer { sig in
        sign(sessionHandle, msg.baseAddress, UInt(msg.count), sig.baseAddress, &length)
      }
    }
    guard signed == 0, length <= bytes.count else { return failure("C_Sign", "Signature refusée", signed) }
    let signature = Data(bytes.prefix(Int(length)))
    let algorithm: SecKeyAlgorithm = dmpSignedInfo == nil ? .rsaSignatureMessagePKCS1v15SHA256 : .rsaSignatureMessagePKCS1v15SHA1
    guard SecKeyIsAlgorithmSupported(publicKey, .verify, algorithm),
          SecKeyVerifySignature(publicKey, algorithm, Data(message.utf8) as CFData, signature as CFData, nil),
          !SecKeyVerifySignature(publicKey, algorithm, Data((message + " altered").utf8) as CFData, signature as CFData, nil) else {
      return failure("verification", "La vérification locale de la signature a échoué")
    }
    return ["success": true, "objects": objects, "certificates": certificates,
            "nationalId": expectedId, "verified": true, "tamperedMessageRejected": true,
            "algorithm": dmpSignedInfo == nil ? "RSA-SHA256 / PKCS#1 v1.5" : "RSA-SHA1 / PKCS#1 v1.5 (lot local)", "message": message,
            "signatureBase64": signature.base64EncodedString(),
            "signingCertificateBase64": certData.base64EncodedString()]

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
// À ajouter après la dernière accolade de MainFlutterWindow.swift.
// Les imports Cocoa et FlutterMacOS existent déjà dans ce fichier.

final class AbakMaintenanceAccess {
  static let shared = AbakMaintenanceAccess()
  private var activeURL: URL?
  private var channel: FlutterMethodChannel?

  func register(with messenger: FlutterBinaryMessenger) {
    let bridge = FlutterMethodChannel(name: "abak/maintenance_access", binaryMessenger: messenger)
    bridge.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      if call.method == "release" {
        self.activeURL?.stopAccessingSecurityScopedResource()
        self.activeURL = nil
        result(nil)
        return
      }
      guard call.method == "authorize",
            let args = call.arguments as? [String: Any],
            let path = args["path"] as? String,
            path.hasPrefix("/"),
            URL(fileURLWithPath: path).lastPathComponent.hasPrefix("abak-maintenance-"),
            !path.split(separator: "/").contains(where: { ["Applications", "Containers", "Group Containers"].contains(String($0)) }) else {
        result(FlutterError(code: "SYNTHETIC_ONLY", message: "Dossier synthétique requis.", details: nil))
        return
      }
      let expected = URL(fileURLWithPath: path, isDirectory: true).standardizedFileURL
      guard expected.path == path else { result(nil); return }
      let panel = NSOpenPanel()
      panel.canChooseDirectories = true
      panel.canChooseFiles = false
      panel.allowsMultipleSelection = false
      panel.canCreateDirectories = false
      panel.title = "Maintenance — autoriser uniquement le dossier synthétique"
      panel.message = "Sélectionnez exactement : \(path)"
      panel.prompt = "Autoriser la recette"
      panel.directoryURL = expected
      NSApp.activate(ignoringOtherApps: true)
      guard panel.runModal() == .OK, let selected = panel.url,
            selected.standardizedFileURL.path == path,
            selected.resolvingSymlinksInPath().path == path else {
        result(nil)
        return
      }
      let started = selected.startAccessingSecurityScopedResource()
      guard (try? String(contentsOf: selected.appendingPathComponent("SYNTHETIC-ONLY"), encoding: .utf8)) == "ABAK-MAINTENANCE-SYNTHETIC-V1\n" else {
        if started { selected.stopAccessingSecurityScopedResource() }
        result(nil)
        return
      }
      self.activeURL?.stopAccessingSecurityScopedResource()
      self.activeURL = started ? selected : nil
      result(path)
    }
    channel = bridge
  }
}

final class AbakDirectoryAccessBridge {
  static let shared = AbakDirectoryAccessBridge()

  private var channel: FlutterMethodChannel?
  private var activeURLs: [String: URL] = [:]

  private init() {}

  func register(with messenger: FlutterBinaryMessenger) {
    guard channel == nil else { return }
    let newChannel = FlutterMethodChannel(
        name: "abak/directory_access",
        binaryMessenger: messenger
    )
    newChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterError(
            code: "UNAVAILABLE",
            message: "Service d’accès aux dossiers indisponible.",
            details: nil
        ))
        return
      }
      self.handle(call, result: result)
    }
    channel = newChannel
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    do {
      switch call.method {
      case "getInstallationLocation":
        let actualURL = Bundle.main.bundleURL
            .resolvingSymlinksInPath()
            .standardizedFileURL

        let expectedURL = URL(
            fileURLWithPath: "/Applications/abak_desktop_companion.app",
            isDirectory: true
        ).resolvingSymlinksInPath().standardizedFileURL

        result([
                 "actualPath": actualURL.path,
                 "expectedPath": expectedURL.path,
                 "isInstalled": actualURL.path == expectedURL.path,
               ])

      case "openApplicationsFolder":
        let opened = NSWorkspace.shared.open(
            URL(fileURLWithPath: "/Applications", isDirectory: true)
        )
        result(opened)

      case "openDocx", "openPdf":
        let extensionName = call.method == "openPdf" ? "pdf" : "docx"
        let documentKind = extensionName.uppercased()
        guard let path = args["path"] as? String, path.hasPrefix("/"),
              !path.contains("\0") else {
          throw NSError(domain: "AbakDocumentOpen", code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Chemin du \(documentKind) invalide."])
        }
        let document = URL(fileURLWithPath: path).standardizedFileURL
        let resolved = document.resolvingSymlinksInPath()
        guard document.pathExtension.lowercased() == extensionName,
              resolved.pathExtension.lowercased() == extensionName,
              try resolved.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true,
              FileManager.default.isReadableFile(atPath: resolved.path) else {
          throw NSError(domain: "AbakDocumentOpen", code: 2,
                        userInfo: [NSLocalizedDescriptionKey: "Le \(documentKind) est absent ou inaccessible. Vérifiez l’accès au dossier des documents."])
        }
        guard let application = NSWorkspace.shared.urlForApplication(toOpen: document) else {
          throw NSError(domain: "AbakDocumentOpen", code: 3,
                        userInfo: [NSLocalizedDescriptionKey: "Aucune application par défaut pour les fichiers \(documentKind). Choisissez-en une dans le Finder."])
        }
        // Open the document with its registered application explicitly. Launching
        // an already-running application with a custom Apple event can succeed
        // without opening the requested document.
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.open([document], withApplicationAt: application,
                                configuration: configuration) { _, error in
          DispatchQueue.main.async {
            if let error = error {
              result(FlutterError(code: "\(documentKind)_OPEN_FAILED",
                                  message: error.localizedDescription, details: nil))
            } else {
              result(nil)
            }
          }
        }

      case "chooseDirectory":
        let readOnly = args["readOnly"] as? Bool ?? false
        let expectedPath = args["expectedPath"] as? String
        if let expectedPath {
          guard readOnly, expectedPath.hasPrefix("/"),
                expectedPath != "/",
                URL(fileURLWithPath: expectedPath).standardizedFileURL.path == expectedPath else {
            throw NSError(domain: "AbakDirectoryAccess", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Chemin de dossier invalide."])
          }
        }
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = !readOnly
        panel.treatsFilePackagesAsDirectories = readOnly
        panel.title = args["title"] as? String ?? "Choisir un dossier"
        panel.prompt = readOnly ? "Autoriser la lecture" : "Autoriser ce dossier"
        if readOnly, let initialPath = args["initialPath"] as? String,
           initialPath.hasPrefix("/") {
          panel.directoryURL = URL(fileURLWithPath: initialPath).deletingLastPathComponent()
        }
        if let expectedPath {
          panel.directoryURL = URL(fileURLWithPath: expectedPath).deletingLastPathComponent()
          panel.message = "Sélectionnez ce dossier pour autoriser sa lecture : \(expectedPath)"
        }
        guard panel.runModal() == .OK, let url = panel.url else {
          result(nil)
          return
        }
        if let expectedPath, url.standardizedFileURL.path != expectedPath {
          throw NSError(domain: "AbakDirectoryAccess", code: 3,
                        userInfo: [NSLocalizedDescriptionKey: "Sélectionnez exactement le dossier indiqué, ou corrigez le chemin dans le formulaire."])
        }
        let bookmark = try url.bookmarkData(
            options: readOnly ? [.withSecurityScope, .securityScopeAllowOnlyReadAccess] : [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        result(try activate(bookmark, readOnly: readOnly))

      case "restoreDirectory":
        guard let encoded = args["bookmark"] as? String,
              let bookmark = Data(base64Encoded: encoded) else {
          result(FlutterError(
              code: "INVALID_BOOKMARK",
              message: "Autorisation de dossier absente ou illisible.",
              details: nil
          ))
          return
        }
        result(try activate(bookmark, readOnly: args["readOnly"] as? Bool ?? false))

      case "releaseDirectory":
        guard let token = args["token"] as? String else {
          result(FlutterError(
              code: "INVALID_TOKEN",
              message: "Identifiant d’accès absent.",
              details: nil
          ))
          return
        }
        if let url = activeURLs.removeValue(forKey: token) {
          url.stopAccessingSecurityScopedResource()
        }
        result(nil)

      case "releaseAll":
        for url in activeURLs.values {
          url.stopAccessingSecurityScopedResource()
        }
        activeURLs.removeAll()
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    } catch {
      result(FlutterError(
          code: "DIRECTORY_ACCESS_FAILED",
          message: "Impossible d’accéder au dossier. Vérifiez sa disponibilité ou autorisez-le à nouveau.",
          details: error.localizedDescription
      ))
    }
  }

  private func activate(_ bookmark: Data, readOnly: Bool = false) throws -> [String: Any] {
    var stale = false
    let url = try URL(
        resolvingBookmarkData: bookmark,
        options: [.withSecurityScope, .withoutUI, .withoutMounting],
        relativeTo: nil,
        bookmarkDataIsStale: &stale
    )

    let started = url.startAccessingSecurityScopedResource()
    var retained = false
    defer {
      if started && !retained {
        url.stopAccessingSecurityScopedResource()
      }
    }

    // Certains dossiers sont déjà accessibles, notamment hors sandbox en Debug.
    // Ne jamais assimiler la seule résolution du chemin à une autorisation.
    let values = try url.resourceValues(forKeys: [.isDirectoryKey])
    guard values.isDirectory == true,
          FileManager.default.isReadableFile(atPath: url.path),
          (readOnly || FileManager.default.isWritableFile(atPath: url.path)) else {
      throw NSError(
          domain: "AbakDirectoryAccess",
          code: 1,
          userInfo: [NSLocalizedDescriptionKey: readOnly
            ? "Dossier indisponible ou accès en lecture refusé."
            : "Dossier indisponible ou accès lecture-écriture refusé."]
      )
    }

    let currentBookmark = stale ? try url.bookmarkData(
        options: readOnly ? [.withSecurityScope, .securityScopeAllowOnlyReadAccess] : [.withSecurityScope],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
    ) : bookmark

    let token = UUID().uuidString
    if started {
      activeURLs[token] = url
      retained = true
    }

    return [
      "path": url.path,
      "bookmark": currentBookmark.base64EncodedString(),
      "token": token,
    ]
  }
}

/// Native preferences recipe ONLY. Registered solely by the signed, isolated
/// recipe branch above. No arbitrary domain argument, no raw plist replacement,
/// no cfprefsd restart, and no application/business database access.
private enum AbakPreferencesRecipe {
  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "abak/preferences_recipe", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      do {
        guard let domain = Bundle.main.bundleIdentifier,
              domain.hasPrefix("fr.abakphysio.maintenance.recipe."),
              (Bundle.main.object(forInfoDictionaryKey: "ABAKPreferencesRecipeOnly") as? Bool == true ||
               (Bundle.main.object(forInfoDictionaryKey: "ABAKCoordinatedRecipeOnly") as? Bool == true &&
                CommandLine.arguments.contains(where: { $0.hasPrefix("--abak-coordinated-phase=") }))) else {
          throw failure("Identité de recette obligatoire.")
        }
        let defaults = UserDefaults.standard
        let args = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "context":
          result(["identity": domain,
                  "target": Bundle.main.object(forInfoDictionaryKey: "ABAKRecipeFolder") as? String ?? ""])
        case "synchronize":
          result(defaults.synchronize())
        case "snapshot":
          guard defaults.synchronize() else { throw failure("Synchronisation impossible.") }
          let values = owned(defaults, domain)
          let data = try PropertyListSerialization.data(fromPropertyList: values, format: .xml, options: 0)
          result(["format": "ABAK-NATIVE-PREFERENCES-RECIPE-1", "identity": domain,
                  "payload": data.base64EncodedString(), "sha256": digest(data),
                  "keys": values.keys.sorted()])
        case "restore":
          // Validate everything before changing even one preference.
          guard let archive = args["archive"] as? [String: Any],
                archive["format"] as? String == "ABAK-NATIVE-PREFERENCES-RECIPE-1",
                archive["identity"] as? String == domain,
                let encoded = archive["payload"] as? String, encoded.utf8.count < 4_000_000,
                let data = Data(base64Encoded: encoded),
                archive["sha256"] as? String == digest(data),
                let values = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
                archive["keys"] as? [String] == values.keys.sorted(),
                values.allSatisfy({ $0.key.hasPrefix("flutter.") && valid($0.value) }),
                let expected = args["expected"] as? String else {
            throw failure("Sauvegarde invalide ou d’une autre identité : restauration refusée.")
          }
          guard defaults.synchronize() else { throw failure("Synchronisation impossible.") }
          let current = try PropertyListSerialization.data(fromPropertyList: owned(defaults, domain), format: .xml, options: 0)
          guard digest(current) == expected else { throw failure("Préférences modifiées depuis l’examen : restauration refusée.") }
          let before = defaults.persistentDomain(forName: domain) ?? [:]
          var merged = before.filter { !$0.key.hasPrefix("flutter.") }
          for (key, value) in values { merged[key] = value }
          defaults.setPersistentDomain(merged, forName: domain)
          guard defaults.synchronize(), NSDictionary(dictionary: owned(defaults, domain)).isEqual(to: values) else {
            defaults.setPersistentDomain(before, forName: domain)
            _ = defaults.synchronize()
            throw failure("Restauration non vérifiée ; état précédent rétabli à vérifier.")
          }
          result(["restored": true, "keys": values.count])
        default:
          result(FlutterMethodNotImplemented)
        }
      } catch {
        result(FlutterError(code: "PREFERENCES_RECIPE_REFUSED", message: error.localizedDescription, details: nil))
      }
    }
  }
  private static func owned(_ defaults: UserDefaults, _ domain: String) -> [String: Any] {
    return (defaults.persistentDomain(forName: domain) ?? [:]).filter { $0.key.hasPrefix("flutter.") }
  }
  private static func valid(_ value: Any) -> Bool {
    if value is String { return true }
    if let number = value as? NSNumber { return number.doubleValue.isFinite }
    if value is [String] { return true }
    return false
  }
  private static func digest(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
  }
  private static func failure(_ message: String) -> NSError {
    NSError(domain: "AbakPreferencesRecipe", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
  }
}
