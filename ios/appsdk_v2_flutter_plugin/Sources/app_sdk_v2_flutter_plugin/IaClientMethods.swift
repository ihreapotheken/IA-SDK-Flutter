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
         * Registers SDK modules for use in the application.
         */
        case register

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
    private let argumentDecoder = IaArgumentDecoder()

    init(bindings: IaClientBindings!) {
        self.bindings = bindings
    }
    
    /**
     * Registers a handler for method calls from the Flutter side.
     */
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
        case FlutterCall.register.name:
            let arguments = try argumentDecoder.decode(IaRegisterModulesArguments.self, from: call.arguments)
            let modules = arguments.modules
            
            // Map Flutter modules to SDK modules, doing it here and not in decoder because it requires all imports.
            var sdkModules = [IASDKModule]()
            for module in modules {
                switch module {
                case .integrations: sdkModules.append(.integrations)
                case .overTheCounter: sdkModules.append(.overTheCounter)
                case .ordering: sdkModules.append(.ordering)
                case .apofinder: sdkModules.append(.apofinder)
                case .pharmacyDetails: sdkModules.append(.pharmacyDetails)
                case .prescription: sdkModules.append(.prescription)
                case .cardLink: sdkModules.append(.cardLink)
                }
            }
            
            IASDK.register(sdkModules)
            return nil

        case FlutterCall.initIaSdk.name:
            let arguments = try argumentDecoder.decode(IaInitSdkArguments.self, from: call.arguments)
            let initializationOptions = arguments.initialization.mappedToSDK()
            
            // Set delegate
            IASDK.setDelegate(IaClientDelegate(channel: bindings.channel))
            
            // Configuration
            IASDK.setEnvironment(arguments.serverEnvironment.mappedToSDK())
            IASDK.configuration.apiKey = arguments.accessKey
            IASDK.configuration.clientID = arguments.clientId
            IASDK.configuration.shouldLoadRemoteStyleConfiguration = arguments.shouldFetchThemeFromRemote
            IASDK.configuration.footer.shouldShowAppSettings = arguments.footer.shouldShowAppSettings
            IASDK.configuration.footer.shouldShowDataProcessing = arguments.footer.shouldShowDataProcessing
            IASDK.configuration.footer.shouldShowImprint = arguments.footer.shouldShowImprint

            // @TODO: remove, just for testing
            IASDK.QA.setQAFeatures([.showTestPharmaciesOnApofinder])
            
            // Auto initialization is enabled to match Android behavior in terms of prerequisites.
            IASDK.configuration.isAutoInitializationEnabled = true
            IASDK.configuration.defaultInitializationOptions = initializationOptions

            // Initialization (we don't pass prerequisites options here to match android), isAutoInitializationEnabled is true which means it will run
            // prerequisites when some screen is shown.
            try await IASDK.initialize(shouldShowIndicator: initializationOptions.shouldShowIndicator, prerequisitesOptions: nil)
            return nil

        case FlutterCall.setPharmacyId.name:
            let arguments = try argumentDecoder.decode(IaSetPharmacyIdArguments.self, from: call.arguments)
            try await IASDK.Pharmacy.setPharmacyID(try arguments.pharmacyIdInt)
            return true

        case FlutterCall.clearCart.name:
            try await IAOrderingSDK.deleteCart()
            return nil

        case FlutterCall.setGuestUserData.name:
            let arguments = try argumentDecoder.decode(IaSetGuestUserDataArguments.self, from: call.arguments)
            try await IASDK.setUserData(arguments.mappedToSDK())
            return nil

        case FlutterCall.logout.name:
            try await IASDK.deleteAllUserRelatedData()
            return nil

        case FlutterCall.launchRoute.name:
            let arguments = try argumentDecoder.decode(IaLaunchRouteArguments.self, from: call.arguments)
            let screen = try arguments.view.iaScreen()
            screen.present()
            return nil

        case FlutterCall.transferPrescriptions.name:
            let arguments = try IaTransferPrescriptionsArguments(from: call.arguments)
            let mapped = arguments.mappedToSDK()

            try await IAOrderingSDK.transferPrescriptions(
                images: mapped.images,
                pdfs: mapped.pdfs,
                codes: mapped.codes,
                orderID: mapped.orderId,
                showActivityIndicator: true,
                finishAction: .openCart
            )
            return nil

        case FlutterCall.finishAllActivities.name:
            // @TODO: This will work for now but we will have to discuss how to best implement this.
            UIApplication.shared.rootViewController?.dismiss(animated: true)
            return nil

        default:
            return FlutterMethodNotImplemented
        }
    }
}
