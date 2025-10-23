import IACore
import IAIntegrations
import IAOverTheCounter
import IAOrdering
import Flutter

/**
 * Flutter client service call handler.
 */
@MainActor
internal class IaClientMethods {
  /**
   * Collection of available method invocation identifiers.
   */
  enum FlutterCall : CaseIterable {
    /**
     * Allocates the SDK runtime resources.
     */
    case initIaSdk
    
    /**
     * Places a new [UIViewController] object into the navigation stack.
     */
    case launchRoute
    
    /**
     * Forwards a collection of prescription objects with the ia.de checkout services.
     */
    case transferPrescriptions
    
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
      guard
        let accessKey = args["accessKey"] as? String,
        let clientId = args["clientId"] as? String,
        let serverEnvString = args["serverEnvironment"] as? String
      else {
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "Missing or invalid argument types. Expected String values for accessKey, clientId, and serverEnvironment.",
            details: nil
          )
        )
      }
      let serverEnv: EnvironmentID
      switch serverEnvString {
      case "development":
        serverEnv = EnvironmentID.dev
        break
      case "staging":
        serverEnv = EnvironmentID.staging
        break
      case "production":
        serverEnv = EnvironmentID.prod
        break
      default:
        return result(
          FlutterError(
            code: "ARG_ERROR",
            message: "Invalid environment ID: \(serverEnvString)",
            details: nil
          )
        )
      }
      IASDK.configuration.apiKey = accessKey
      IASDK.configuration.clientID = clientId
      IASDK.setEnvironment(serverEnv)
      IASDK.register([
        .integrations,
        .overTheCounter,
        .ordering,
        .apofinder
      ])
      Task.init {
        do {
          let prerequisitesOptions = IASDKPrerequisitesOptions(
            shouldShowIndicator: true,
            isCancellable: true,
            isAnimated: true,
            shouldRunLegal: false,
            shouldRunOnboarding: false,
            shouldRunApofinder: true,
          )
          let _ = try await IASDK.initialize(
            options: .init(
              prerequisitesOptions: prerequisitesOptions
            ),
          )
          result(nil)
        } catch {
          result(
            FlutterError(
              code: "INIT_ERROR",
              message: "\(String(describing: error)) \(error.localizedDescription)",
              details: nil)
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
            message: "View identifier must be provided as a String type argument \"viewId\".",
            details: nil
          )
        )
      }
      let baseViewController: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController
      func getTopViewController(base: UIViewController? = baseViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
          return getTopViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController,
           let selected = tab.selectedViewController {
          return getTopViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
          return getTopViewController(base: presented)
        }
        return base
      }
      guard
        let topViewController = getTopViewController()
      else {
        return result(
          FlutterError(
            code: "LOGIC_ERROR",
            message: "No UIViewController object found.",
            details: nil
          )
        )
      }
      let viewController = IaClientViewUIKitViewController(viewId: args)
      let navigationController = UINavigationController(rootViewController: viewController)
      navigationController.modalPresentationStyle = .fullScreen
      topViewController.present(navigationController, animated: true)
      result(nil)
      break
    case FlutterCall.transferPrescriptions.name:
      guard let data = call.arguments as? [String: Any] else {
        result(FlutterError(
          code: "ARG_ERROR",
          message: "Prescription data must be provided as a Dictionary<String, Any> type argument.",
          details: nil
        ))
        break
      }
      let prescriptionImages = data["images"]
      if let prescriptionImages = prescriptionImages {
        guard
          let array = prescriptionImages as? [FlutterStandardTypedData]
        else {
          result(FlutterError(
            code: "ARG_ERROR",
            message: "Prescription image data must be provided as an Array<ByteData> type argument \"images\".",
            details: nil
          ))
          break
        }
      }
      let prescriptionPdfs = data["pdfs"]
      if let prescriptionPdfs = prescriptionPdfs {
        guard
          let array = prescriptionPdfs as? [FlutterStandardTypedData]
        else {
          result(FlutterError(
            code: "ARG_ERROR",
            message: "Prescription PDF data must be provided as an Array<ByteData> type argument \"pdfs\".",
            details: nil
          ))
          break
        }
      }
      let prescriptionCodes = data["codes"]
      if let prescriptionCodes = prescriptionCodes {
        guard
          let outer = prescriptionCodes as? [[String]]
        else {
          result(FlutterError(
            code: "ARG_ERROR",
            message: "Prescription code data must be provided as an Array<Array<String>> type argument \"codes\".",
            details: nil
          ))
          break
        }
      }
      let images: [Data] = (data["images"] as? [FlutterStandardTypedData])?.map { $0.data } ?? []
      let pdfs: [Data] = (data["pdfs"] as? [FlutterStandardTypedData])?.map { $0.data } ?? []
      let codes: [[String]] = data["codes"] as? [[String]] ?? []
      // TODO
      result(nil)
      break
    default:
      return result(FlutterMethodNotImplemented)
    }
  }
}
