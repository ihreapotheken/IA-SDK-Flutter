import Combine
import Flutter
import IACore
import IAIntegrations

@MainActor
final class IASDKPlugin {
    private let bindings: IaClientBindings
    private let iaSdkWrapper = IASDKWrapper()
    private let pharmacyWrapper = IAPharmacyWrapper()
    private let orderingWrapper = IAOrderingWrapper()
    private let overTheCounterWrapper = IAOverTheCounterWrapper()
    private let prescriptionWrapper = IAPrescriptionWrapper()
    private let integrationsWrapper = IAIntegrationsWrapper()
    private let delegate: IaClientDelegate
    private var cancellables = Set<AnyCancellable>()

    init(bindings: IaClientBindings) {
        self.bindings = bindings
        self.delegate = IaClientDelegate(channel: bindings.channel)
        IASDK.setDelegate(delegate)
        observeInitializationState()
        let channel = bindings.channel
        PrescriptionScannerCameraController.shared.onError = { error in
            channel.invokeMethod("prescriptionScannerCameraError", arguments: ["message": error.localizedDescription])
        }
    }

    private func observeInitializationState() {
        let channel = bindings.channel
        IASDK.initializationStatePublisher
            .map(\.flutterName)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { state in
                channel.invokeMethod("sdkInitializationStateChanged", arguments: ["state": state])
            }
            .store(in: &cancellables)
    }
    
    /// Registers a handler for method calls from the Flutter side.
    func callHandler(call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            do {
                let returnValue = try await callHandlerInternal(call: call)
                result(returnValue)
            } catch {
                print(">>> callHandler error: \(error)")
                result(error.flutterError(methodName: call.method))
            }
        }
    }
    
    func callHandlerInternal(call: FlutterMethodCall) async throws -> Any? {
        switch call.method {
                
            case FlutterCall.register.name:
                return try await iaSdkWrapper.register(arguments: call.arguments)
                
            case FlutterCall.initialize.name:
                return try await iaSdkWrapper.initialize(arguments: call.arguments, delegate: delegate)
                
            case FlutterCall.setPharmacyId.name:
                return try await iaSdkWrapper.setPharmacyId(arguments: call.arguments)
                
            case FlutterCall.setGuestUserData.name:
                return try await iaSdkWrapper.setGuestUserData(arguments: call.arguments)
                
            case FlutterCall.logout.name:
                return try await iaSdkWrapper.deleteAllUserRelatedData(arguments: call.arguments)
                            
            case FlutterCall.launchRoute.name:
                return try await iaSdkWrapper.launchRoute(arguments: call.arguments, delegate: delegate)
                
            case FlutterCall.finishAllActivities.name:
                return try await iaSdkWrapper.finishAllActivities(arguments: call.arguments)
                
            case FlutterCall.clearCart.name:
                return try await orderingWrapper.clearCart(arguments: call.arguments)
                
            case FlutterCall.transferPrescriptions.name:
                return try await orderingWrapper.transferPrescriptions(arguments: call.arguments)

            case FlutterCall.transferSDKv1UserData.name:
                return try await iaSdkWrapper.transferSDKv1UserData()

            case FlutterCall.isInitialized.name:
                return try await iaSdkWrapper.isInitialized()

            case FlutterCall.deleteUser.name:
                return try await iaSdkWrapper.deleteUser()

            case FlutterCall.getEnvironment.name:
                return try await iaSdkWrapper.getEnvironment()

            case FlutterCall.cleanCache.name:
                return try await iaSdkWrapper.cleanCache(arguments: call.arguments)

            case FlutterCall.getPharmacyId.name:
                return try await iaSdkWrapper.getPharmacyId()

            case FlutterCall.getCartDetails.name:
                return try await orderingWrapper.getCartDetails(arguments: call.arguments)

            case FlutterCall.deleteOrderHistory.name:
                return try await orderingWrapper.deleteOrderHistory()

            case FlutterCall.setUserBillingAddress.name:
                return try await iaSdkWrapper.setUserBillingAddress(arguments: call.arguments)

            case FlutterCall.setUserDeliveryAddress.name:
                return try await iaSdkWrapper.setUserDeliveryAddress(arguments: call.arguments)

            case FlutterCall.legacySetupAsCoreApp.name:
                return try await iaSdkWrapper.legacySetupAsCoreApp()

            case FlutterCall.setShouldShowMascotIllustrations.name:
                return try await iaSdkWrapper.setShouldShowMascotIllustrations(arguments: call.arguments)

            case FlutterCall.clearPharmacyId.name:
                return try await iaSdkWrapper.clearPharmacyId()

            case FlutterCall.resetPrerequisites.name:
                return try await iaSdkWrapper.resetPrerequisites()

            case FlutterCall.clearProductGridCache.name:
                return try await overTheCounterWrapper.clearProductGridCache()

            case FlutterCall.resetLegalDisclaimer.name:
                return try await iaSdkWrapper.resetLegalDisclaimer()

            case FlutterCall.setIsOnboardingShown.name:
                return try await iaSdkWrapper.setIsOnboardingShown(arguments: call.arguments)

            case FlutterCall.clearUserBillingAddress.name:
                return try await iaSdkWrapper.clearUserBillingAddress()

            case FlutterCall.clearUserDeliveryAddress.name:
                return try await iaSdkWrapper.clearUserDeliveryAddress()

            case FlutterCall.presentLogs.name:
                return try await iaSdkWrapper.presentLogs()

            case FlutterCall.getUserId.name:
                return try await iaSdkWrapper.getUserId()

            case FlutterCall.getPharmacy.name:
                return try await pharmacyWrapper.getPharmacy(arguments: call.arguments)

            case FlutterCall.savePharmacyId.name:
                return try await iaSdkWrapper.savePharmacyId(arguments: call.arguments)

            case FlutterCall.setPrescriptionScannerCameraState.name:
                let args = call.arguments as? [String: Any] ?? [:]
                let controller = PrescriptionScannerCameraController.shared
                if let isOn = args["isOn"] as? Bool {
                    controller.state.isOn = isOn
                }
                if let isFlashlightOn = args["isFlashlightOn"] as? Bool {
                    controller.state.isFlashlightOn = isFlashlightOn
                }
                if let isPreviewPaused = args["isPreviewPaused"] as? Bool {
                    controller.state.isPreviewPaused = isPreviewPaused
                }
                return nil

            case FlutterCall.getInitializationState.name:
                return IASDK.initializationState.flutterName

            case FlutterCall.removeAllCachedResponses.name:
                IASDK.QA.removeAllCachedResponses()
                return nil

            case FlutterCall.setLogMessageForwardingEnabled.name:
                let args = call.arguments as? [String: Any] ?? [:]
                delegate.isLogMessageForwardingEnabled = args["enabled"] as? Bool ?? false
                return nil

            default:
                return FlutterMethodNotImplemented
        }
    }
}
