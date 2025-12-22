import Combine
import Flutter
import IACore
import IAIntegrations
import IAOrdering
import IAOverTheCounter
import IAPharmacy

/// Flutter client service call handler.
@MainActor
internal class IaClientMethods {
  /**
   * Collection of available method invocation identifiers.
   */
  enum FlutterCall: CaseIterable {
    /**
     * Allocates the SDK runtime resources.
     */
    case initIaSdk
    
    /**
     * Selects a pharmacy by providing an identifier.
     */
    case setPharmacyId
    
    /**
     * Resets the state of user cart, clearing any added products or prescriptions.
     */
    case clearCart
    
    /**
     * Forwards the client personal information to the ia.de library for checkout purposes.
     */
    case setGuestUserData
    
    /**
     * Resets the user data and onboarding status (pharmacy selection, user consents statuses).
     */
    case logout
    
    /**
     * Places a new [UIViewController] object into the navigation stack.
     */
    case launchRoute
    
    /**
     * Forwards a collection of prescription objects with the ia.de checkout services.
     */
    case transferPrescriptions
    
    /**
     * Closes any overlaying ia.de screen contents.
     */
    case finishAllActivities
    
    /**
     * Configures footer visibility settings.
     */
    case configureFooter
    
    /**
     * String identifier getter definition.
     */
    var name: String {
      return String(describing: self)
    }
  }
  
  /**
   * Flutter SDK host app bindings definitions.
   */
  private let bindings: IaClientBindings!
  private var isRegistered: Bool = false
  
  init(bindings: IaClientBindings!) {
    self.bindings = bindings
  }
  
  
  /**
   * Registers a handler for method calls from the Flutter side.
   */
  func callHandler(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case FlutterCall.initIaSdk.name:
      let args = call.arguments
      guard
        let args = args as? [String: Any]
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "Arguments for initIaSdk must be of Dictionary type.",
            details: nil
          )
        )
      }

      // Decode and print configuration
      guard let arguments = IaInitSdkArguments.fromJson(args) else {
          return 
      }

      print("IA SDK Configuration: \(arguments) \(arguments.serverEnvironment.mappedToSDK())")

      guard
        let accessKey = args["accessKey"] as? String,
        let clientId = args["clientId"] as? String,
        let serverEnvString = args["serverEnvironment"] as? String
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message:
              "Missing or invalid argument types. Expected String values for accessKey, clientId, and serverEnvironment.",
            details: nil
          )
        )
      }

      if !isRegistered {
        isRegistered = true
        IASDK.configuration.apiKey = accessKey
        IASDK.configuration.clientID = clientId
          IASDK.setEnvironment(arguments.serverEnvironment.mappedToSDK())
        // @TODO: remove, just for testing
        IASDK.QA.setQAFeatures([.showTestPharmaciesOnApofinder])
        IASDK.register([
          .integrations,
          .overTheCounter,
          .ordering,
          .apofinder,
          .pharmacyDetails,
          .prescription,
        ])
      }
      IASDK.setDelegate(IaClientDelegate(channel: bindings.channel))
      
      // @TODO pass this via configuration.
      let prerequsitesOptions = IASDKPrerequisitesOptions(
        shouldShowIndicator: false, 
        isCancellable: false, 
        isAnimated: true, 
        shouldRunLegal: true, 
        shouldRunOnboarding: false,
        shouldRunApofinder: true
      )
      
      // @TODO: Auto initialization is enabled to match Android behavior in terms of prerequisites. Values are hardcoded.
      IASDK.configuration.isAutoInitializationEnabled = true
      
      Task.init {
        do {
          let _ = try await IASDK.initialize(
            options: .init(
              shouldShowIndicator: false,
              prerequisitesOptions: nil
            ),
          )
          result(nil)
        } catch {
          result(
            FlutterError(
              code: "INIT_ERROR",
              message: "\(String(describing: error)) \(error.localizedDescription)",
              details: nil,
            )
          )
        }
      }
      break
    case FlutterCall.setPharmacyId.name:
      let args = call.arguments
      guard
        let pharmacyIdStr = args as? String
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "Pharmacy identifier must be provided as a String type argument.",
            details: nil,
          )
        )
      }
      guard
        let pharmacyId = Int(pharmacyIdStr)
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "Pharmacy identifier string must be provided in Int format: \(pharmacyIdStr).",
            details: nil,
          )
        )
      }
      Task.init {
        do {
          try await IASDK.Pharmacy.setPharmacyID(pharmacyId)
          result(true)
        } catch {
          result(
            FlutterError(
              code: "SET_PHARMACY_ERROR",
              message: "\(String(describing: error)) \(error.localizedDescription)",
              details: nil,
            )
          )
        }
      }
      break
    case FlutterCall.clearCart.name:
      Task.init {
        do {
          try await IAOrderingSDK.deleteCart()
          result(true)
        } catch {
          result(
            FlutterError(
              code: "CLEAR_CART_ERROR",
              message: "\(String(describing: error)) \(error.localizedDescription)",
              details: nil,
            )
          )
        }
      }
      break
    case FlutterCall.setGuestUserData.name:
      let args = call.arguments
      guard
        let args = args as? [String: Any]
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "Arguments for initIaSdk must be of Dictionary type.",
            details: nil
          )
        )
      }
      guard
        let salutation = args["salutation"] as? String,
        let firstName = args["firstName"] as? String,
        let lastName = args["lastName"] as? String,
        let email = args["email"] as? String,
        let phoneNumberCountryCode = args["phoneNumberCountryCode"] as? String,
        let phoneNumberWithoutCountryCode = args["phoneNumberWithoutCountryCode"] as? String
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "Missing or invalid argument types.",
            details: nil
          )
        )
      }
      let iaSalutation: IAUserSalutation
      switch salutation.lowercased() {
      case "herr":
        iaSalutation = IAUserSalutation.male
      case "frau":
        iaSalutation = IAUserSalutation.female
      case "keine angabe":
        iaSalutation = IAUserSalutation.notSpecified
      default:
        iaSalutation = IAUserSalutation.diverse
      }
      Task.init {
        do {
          let userData = IAUserData(
            salutation: iaSalutation,
            firstName: firstName,
            lastName: lastName,
            countryCode: phoneNumberCountryCode,
            phoneNumber: phoneNumberWithoutCountryCode,
            email: email,
          )
          try await IASDK.setUserData(userData)
          result(nil)
        } catch {
          result(
            FlutterError(
              code: "SET_GUEST_USER_DATA_ERROR",
              message: "\(String(describing: error)) \(error.localizedDescription)",
              details: nil,
            )
          )
        }
      }
      break
    case FlutterCall.logout.name:
      Task.init {
        do {
          try await IASDK.deleteAllUserRelatedData()
          result(nil)
        } catch {
          result(
            FlutterError(
              code: "LOGOUT_ERROR",
              message: "\(String(describing: error)) \(error.localizedDescription)",
              details: nil,
            )
          )
        }
      }
      break
    case FlutterCall.launchRoute.name:
      let args = call.arguments
      guard
        let args = args as? String
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "View identifier must be provided as a String type argument.",
            details: nil,
          )
        )
      }
      IaClientViews.startScreen.iaScreen().present()
      result(nil)
      break
    case FlutterCall.transferPrescriptions.name:
      guard let data = call.arguments as? [String: Any] else {
        result(
          FlutterError(
            code: "ARG_ERROR",
            message:
              "Prescription data must be provided as a Dictionary<String, Any> type argument.",
            details: nil
          ))
        break
      }
      let prescriptionImages = data["images"]
      if let prescriptionImages = prescriptionImages {
        guard
          let array = prescriptionImages as? [FlutterStandardTypedData]
        else {
          result(
            FlutterError(
              code: "ARG_ERROR",
              message:
                "Prescription image data must be provided as an Array<ByteData> type argument \"images\".",
              details: nil
            )
          )
          break
        }
      }
      let prescriptionPdfs = data["pdfs"]
      if let prescriptionPdfs = prescriptionPdfs {
        guard
          let array = prescriptionPdfs as? [FlutterStandardTypedData]
        else {
          result(
            FlutterError(
              code: "ARG_ERROR",
              message:
                "Prescription PDF data must be provided as an Array<ByteData> type argument \"pdfs\".",
              details: nil
            ))
          break
        }
      }
      let prescriptionCodes = data["codes"]
      if let prescriptionCodes = prescriptionCodes {
        guard
          let outer = prescriptionCodes as? [String]
        else {
          result(
            FlutterError(
              code: "ARG_ERROR",
              message:
                "Prescription code data must be provided as an Array<String> type argument \"codes\".",
              details: nil
            ))
          break
        }
      }
      let images: [Data] = (data["images"] as? [FlutterStandardTypedData])?.map { $0.data } ?? []
      let pdfs: [Data] = (data["pdfs"] as? [FlutterStandardTypedData])?.map { $0.data } ?? []
      let codes: [String] = data["codes"] as? [String] ?? []
      let orderId: String? = data["orderId"] as? String
      Task.init {
        do {
          try await IAOrderingSDK.transferPrescriptions(
            images: images,
            pdfs: pdfs.map { pdfBytes in PDFPrescription(data: pdfBytes) },
            codes: codes,
            orderID: orderId,
            showActivityIndicator: true,
            finishAction: .openCart,
          )
          result(nil)
        } catch {
          result(
            FlutterError(
              code: "PRESCRIPTION_TRANSFER_ERROR",
              message: "\(String(describing: error)) \(error.localizedDescription)",
              details: nil,
            )
          )
        }
      }
      break
    case FlutterCall.finishAllActivities.name:
      // @TODO: This will work for now but we will have to discuss how to best implement this.
      UIApplication.shared.rootViewController?.dismiss(animated: true)
      result(nil)
      break
    case FlutterCall.configureFooter.name:
      let args = call.arguments
      guard
        let args = args as? [String: Any]
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "Arguments for configureFooter must be of Dictionary type.",
            details: nil
          )
        )
      }
      guard
        let shouldShowDataProcessing = args["shouldShowDataProcessing"] as? Bool,
        let shouldShowAppSettings = args["shouldShowAppSettings"] as? Bool,
        let shouldShowImprint = args["shouldShowImprint"] as? Bool
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "Missing or invalid argument types. Expected Bool values for shouldShowDataProcessing, shouldShowAppSettings, and shouldShowImprint.",
            details: nil
          )
        )
      }
      IASDK.configuration.footer.shouldShowDataProcessing = shouldShowDataProcessing
      IASDK.configuration.footer.shouldShowAppSettings = shouldShowAppSettings
      IASDK.configuration.footer.shouldShowImprint = shouldShowImprint
      result(nil)
      break
    default:
      return result(FlutterMethodNotImplemented)
    }
  }
}
