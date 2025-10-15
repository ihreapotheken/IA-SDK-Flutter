import IACore
import IAIntegrations
import IAOverTheCounter
import IAOrdering

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
      guard 
        let serverEnvironment = EnvironmentID(rawValue: serverEnvString) 
      else {
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
      IASDK.setEnvironment(serverEnvironment)
      IASDK.delegate = bindings.delegate
      IAIntegrationsSDK.register()
      IAOverTheCounterSDK.register()
      IAOrderingSDK.register(delegate: bindings.delegate)
      Task.init {
        do {
            let _ = try await IASDK.initialize(options: .init(
              prerequisitesOptions: IASDKPrerequisitesOptions(
                shouldShowIndicator: true,
                isCancellable: false,
                isAnimated: true)
              ),
            )
            result(nil)
        } catch {
          result(
            FlutterError(
              code: "INIT_ERROR",
              message: error.localizedDescription,
              details: nil)
          )
        }
      }
      break
    default:
      return result(FlutterMethodNotImplemented)
    }
  }
}
