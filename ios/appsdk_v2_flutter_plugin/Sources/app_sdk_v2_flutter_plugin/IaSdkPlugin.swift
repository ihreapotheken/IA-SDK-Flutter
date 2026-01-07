import Combine
import Flutter
import IACore
import IAIntegrations
import IAOrdering
import IAOverTheCounter
import IAPharmacy

@MainActor
final class IASDKPlugin {
    private let bindings: IaClientBindings
    private let iaSdkWrapper = IASDKWrapper()
    private let pharmacyWrapper = IAPharmacyWrapper()
    private let orderingWrapper = IAOrderingWrapper()
    private let overTheCounterWrapper = IAOverTheCounterWrapper()
    private let prescriptionWrapper = IAPrescriptionWrapper()
    private let integrationsWrapper = IAIntegrationsWrapper()

    init(bindings: IaClientBindings) {
        self.bindings = bindings
        
        // Set delegate
        IASDK.setDelegate(IaClientDelegate(channel: bindings.channel))
    }
    
    /// Registers a handler for method calls from the Flutter side.
    func callHandler(call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            do {
                let returnValue = try await callHandlerInternal(call: call)
                result(returnValue)
            } catch {
                print(">>> callHandler error: \(error)")    // @TODO remove
                result(error.flutterError(methodName: call.method))
            }
        }
    }
    
    func callHandlerInternal(call: FlutterMethodCall) async throws -> Any? {
        switch call.method {
            
        // MARK: - IA SDK -
        
        case FlutterCall.register.name:
            return try await iaSdkWrapper.register(arguments: call.arguments)
            
        case FlutterCall.initIaSdk.name:
            return try await iaSdkWrapper.initialize(arguments: call.arguments)
            
        case FlutterCall.setPharmacyId.name:
            return try await iaSdkWrapper.setPharmacyId(arguments: call.arguments)
            
        case FlutterCall.setGuestUserData.name:
            return try await iaSdkWrapper.setGuestUserData(arguments: call.arguments)
            
        case FlutterCall.logout.name:
            return try await iaSdkWrapper.deleteAllUserRelatedData(arguments: call.arguments)
                        
        case FlutterCall.launchRoute.name:
            return try await iaSdkWrapper.launchRoute(arguments: call.arguments)
            
        case FlutterCall.finishAllActivities.name:
            return try await iaSdkWrapper.finishAllActivities(arguments: call.arguments)
            
        // MARK: - Ordering -
        
        case FlutterCall.clearCart.name:
            return try await orderingWrapper.clearCart(arguments: call.arguments)
            
        case FlutterCall.transferPrescriptions.name:
            return try await orderingWrapper.transferPrescriptions(arguments: call.arguments)
            
        default:
            return FlutterMethodNotImplemented
        }
    }
}
