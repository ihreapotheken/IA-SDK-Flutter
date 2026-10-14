import Flutter
import Foundation
import Combine
import IACore
import IAIntegrations
import UIKit

@MainActor
final class IASDKWrapper {
    private let argumentDecoder = IaArgumentDecoder()

    func initialize(arguments: Any, delegate: IaClientDelegate) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaInitSdkArguments.self, from: arguments)
        // After a failed initialization, an SDK screen can run the initialization and prerequisites itself. The SDK
        // rejects another initialization meanwhile, so a retry waits until that's done.
        if IASDK.initializationState.isInProgress {
            for await state in IASDK.initializationStatePublisher.values where !state.isInProgress {
                break
            }
        }
        IaClientDelegate.cardLinkConfiguration = arguments.cardLink
        let initializationOptions = arguments.initialization.mappedToSDK()
        
        // Configuration
        IASDK.setEnvironment(arguments.serverEnvironment.mappedToSDK())
        NotificationCenter.default.post(name: IaClientDelegate.sdkEnvironmentWasSetNotification, object: nil)
        IASDK.configuration.apiKey = arguments.accessKey
        IASDK.configuration.clientID = arguments.clientId
        if let channelId = arguments.initialization.channelId {
            IASDK.configuration.channelID = channelId
        }
        IASDK.configuration.shouldLoadRemoteStyleConfiguration = arguments.shouldFetchThemeFromRemote
        IASDK.configuration.footer.shouldShowAppSettings = arguments.footer.shouldShowAppSettings
        IASDK.configuration.footer.shouldShowDataProcessing = arguments.footer.shouldShowDataProcessing
        IASDK.configuration.footer.shouldShowImprint = arguments.footer.shouldShowImprint
        IASDK.configuration.uiConfiguration = arguments.uiConfiguration.mappedToSDK()
        if let isPickupLockerAndCourierShippingEnabled = arguments.isPickupLockerAndCourierShippingEnabled {
            IASDK.configuration.isPickupLockerAndCourierShippingEnabled = isPickupLockerAndCourierShippingEnabled
        }

        if let appStoreId = arguments.appStoreId {
            IASDK.configuration.appStoreID = appStoreId
        }
        if let hostAppLogFilePath = arguments.hostAppLogFilePath, !hostAppLogFilePath.isEmpty {
            IASDK.configuration.hostAppLogFileURL = URL(fileURLWithPath: hostAppLogFilePath)
        }

        if let qaConfiguration = arguments.qaConfiguration {
            IASDK.QA.setQAFeatures(qaConfiguration.mappedToSDK())
        }
        
        // Auto initialization is enabled to match Android behavior in terms of prerequisites.
        IASDK.configuration.isAutoInitializationEnabled = true
        IASDK.configuration.defaultInitializationOptions = initializationOptions
        
        // Initialization (we don't pass prerequisites options here to match android), isAutoInitializationEnabled is true which means it will run
        // prerequisites when some screen is shown.
        try await IASDK.initialize(shouldShowIndicator: initializationOptions.shouldShowIndicator, prerequisitesOptions: nil)
        return nil
    }
    
    func register(arguments: Any) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaRegisterModulesArguments.self, from: arguments)
        let modules = arguments.modules
        var sdkModules = [IASDKModule]()
        if modules.contains(.integrations) {
            sdkModules.append(.integrations)
        }
        if modules.contains(.apofinder) {
            sdkModules.append(.apofinder)
        }
        IASDK.register(sdkModules)
        return nil
    }
    
    func setPharmacyId(arguments: Any) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaSetPharmacyIdArguments.self, from: arguments)
        try await IASDK.Pharmacy.setPharmacyID(try arguments.pharmacyIdInt)
        return true
    }
    
    func setGuestUserData(arguments: Any) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaSetGuestUserDataArguments.self, from: arguments)
        try await IASDK.setUserData(arguments.mappedToSDK())
        return nil
    }
    
    func deleteAllUserRelatedData(arguments: Any) async throws -> Any? {
        try await IASDK.clearAllData()
        return nil

    }
    
    func launchRoute(arguments: Any, delegate: IaClientDelegate) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaLaunchRouteArguments.self, from: arguments)
        if arguments.viewId == "prerequisiteFlow" {
            return FlutterMethodNotImplemented
        }
        let view = try arguments.view
        // An SDK screen decides once, when it appears, whether to run the initialization and prerequisites. One that
        // appears while the initialization runs would wait for it forever, so it opens once that's done. A retry
        // keeps the earlier failure until it finishes.
        if Self.isInitializing(IASDK.initializationState) {
            for await state in IASDK.initializationStatePublisher.values where !Self.isInitializing(state) {
                break
            }
        }
        if view == .prescriptionScanner || view == .ePrescriptionScanner {
            PrescriptionScannerCameraController.shared.reset()
        }
        let presentedScreen = PresentedScreen()
        let screen = view.iaScreen(
            isCancellable: arguments.isCancellable ?? true,
            focusesOnAppear: arguments.focusesOnAppear,
            controlsScannerCamera: true,
            onApofinderFinish: { [weak delegate] pharmacy in
                // Only the SDK's own Apofinder flow tells the SDK delegate, so the selection is reported here, like
                // Android's Apofinder result.
                presentedScreen.viewController?.presentingViewController?.dismiss(animated: true)
                if let pharmacy {
                    delegate?.apofinderDidChangePharmacy(pharmacy, isFromPrerequisites: false)
                }
            }
        )
        if let viewController = screen.present() {
            presentedScreen.viewController = viewController
            Self.presentedScreens.add(viewController)
        }
        return nil
    }

    /// Whether the initialization runs, as opposed to the prerequisites after a successful one.
    private static func isInitializing(_ state: IASDKInitializationState) -> Bool {
        guard state.isInProgress else { return false }
        if case .success = state.initializationResult { return false }
        return true
    }

    /// The view controller of a launched screen, which its callbacks only know after it's presented.
    private final class PresentedScreen {
        weak var viewController: UIViewController?
    }
    
    func finishAllActivities(arguments: Any) async throws -> Any? {
        // Dismissing the lowest SDK screen also closes everything presented above it, while the host's own
        // screens below it stay open, like on Android.
        guard let sdkScreen = Self.lowestPresentedSDKScreen() else { return nil }
        // A CardLink flow launched while an SDK screen was shown sits on that screen, so it closes too.
        let closesCardLink = Self.containsCardLink(from: sdkScreen)
        sdkScreen.presentingViewController?.dismiss(animated: true) {
            if closesCardLink {
                NotificationCenter.default.post(name: IaClientDelegate.cardLinkDidCloseWithSdkScreensNotification, object: nil)
            }
        }
        return nil
    }

    /// Whether a CardLink screen is pushed or presented on the given screen or above it.
    private static func containsCardLink(from viewController: UIViewController) -> Bool {
        var current: UIViewController? = viewController
        while let viewController = current {
            let stack = [viewController] + ((viewController as? UINavigationController)?.viewControllers ?? [])
            if stack.contains(where: { String(reflecting: type(of: $0)).hasPrefix("IACardLink.") }) {
                return true
            }
            current = viewController.presentedViewController
        }
        return false
    }

    /// Screens presented through launchRoute.
    private static let presentedScreens = NSHashTable<UIViewController>.weakObjects()

    /// Modules whose screens finishAllActivities closes. On Android CardLink isn't one of the SDK's activities,
    /// so a CardLink flow the host launched stays open there, and here too.
    private static let sdkModuleNames = ["IACore", "IAIntegrations", "IAOverTheCounter", "IAOrdering", "IAPharmacy", "IAPrescription"]

    private static func lowestPresentedSDKScreen() -> UIViewController? {
        var viewController = UIApplication.shared.rootViewController?.presentedViewController
        while let current = viewController {
            if isSDKScreen(current) { return current }
            viewController = current.presentedViewController
        }
        return nil
    }

    /// Screens the SDK presented itself are recognized by the module their controller or its root comes from.
    private static func isSDKScreen(_ viewController: UIViewController) -> Bool {
        if presentedScreens.contains(viewController) { return true }
        var candidates = [viewController]
        if let rootViewController = (viewController as? UINavigationController)?.viewControllers.first {
            candidates.append(rootViewController)
        }
        let typeNames = candidates.map { String(reflecting: type(of: $0)) }
        if typeNames.contains(where: { $0.contains("IACardLink.") }) { return false }
        return typeNames.contains { typeName in
            sdkModuleNames.contains { typeName.contains("\($0).") }
        }
    }

    func transferSDKv1UserData() async throws -> Any? {
        await IASDK.transferSDKv1UserData()
        return nil
    }

    func legacySetupAsCoreApp() async throws -> Any? {
        // Needed because of report problem.
        IASDK.register([.integrations])
        // Needed to make requests work, they don't work because SDK config is not fetched and that is needed for ssl stuff.
        IASDK.configuration.legacyIsCoreApp = true
        return nil
    }

    func isInitialized() async throws -> Any? {
        // Matches the initialization state stream and Android: prerequisites don't affect it.
        IASDK.initializationState.flutterName == "initialized"
    }

    func deleteUser() async throws -> Any? {
        try await IASDK.deleteUser()
        return nil
    }

    func getEnvironment() async throws -> Any? {
        let env = IASDK.getEnvironment()
        switch env {
        case .dev:
            return "development"
        case .staging:
            return "staging"
        case .prod:
            return "production"
        }
    }

    func cleanCache(arguments: Any) async throws -> Any? {
        let args = arguments as? [String: Any] ?? [:]
        let initialization = args["initialization"] as? Bool ?? false
        let prerequisites = args["prerequisites"] as? Bool ?? false
        IASDK.cleanCache(initialization: initialization, prerequisites: prerequisites)
        return nil
    }

    func setShouldShowMascotIllustrations(arguments: Any) async throws -> Any? {
        let args = arguments as? [String: Any] ?? [:]
        // Absent value keeps the SDK default rather than silently hiding the mascot.
        let shouldShow = args["shouldShowMascotIllustrations"] as? Bool ?? true
        IASDK.configuration.uiConfiguration.shouldShowMascotIllustrations = shouldShow
        return nil
    }

    func getPharmacyId() async throws -> Any? {
        guard let pharmacyId = IASDK.Pharmacy.getPharmacyID() else {
            return nil
        }
        return String(pharmacyId)
    }

    func savePharmacyId(arguments: Any) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaSetPharmacyIdArguments.self, from: arguments)
        IASDK.Pharmacy.savePharmacyID(try arguments.pharmacyIdInt)
        return nil
    }

    func clearPharmacyId() async throws -> Any? {
        IASDK.Pharmacy.savePharmacyID(nil)
        Self.cleanPrerequisitesCache()
        // The cart belongs to the cleared pharmacy, and the Android SDK empties it too. Without the Ordering module
        // there's no cart.
        if let ordering = try? IASDK.ordering {
            try await ordering.deleteCart()
        }
        return nil
    }

    func resetPrerequisites() async throws -> Any? {
        try await IASDK.Prerequisites.resetAllPrerequisites()
        Self.cleanPrerequisitesCache()
        return nil
    }

    func resetLegalDisclaimer() async throws -> Any? {
        try await IASDK.Prerequisites.resetLegalDisclaimer()
        Self.cleanPrerequisitesCache()
        return nil
    }

    /// The SDK keeps the prerequisites result of the session, so without this the changed prerequisites only apply
    /// after an app restart. Its own `clearAllData` does the same.
    private static func cleanPrerequisitesCache() {
        IASDK.cleanCache(initialization: false, prerequisites: true)
    }

    func setIsOnboardingShown(arguments: Any) async throws -> Any? {
        let args = arguments as? [String: Any] ?? [:]
        guard let isOnboardingShown = args["enabled"] as? Bool else {
            throw IaArgumentError.decodingArgumentFailed(description: "Missing or invalid Bool value for enabled.")
        }
        try await IASDK.Prerequisites.setIsOnboardingShown(isOnboardingShown)
        Self.cleanPrerequisitesCache()
        return nil
    }

    func clearUserBillingAddress() async throws -> Any? {
        try await IASDK.setUserBillingAddress(nil)
        return nil
    }

    func clearUserDeliveryAddress() async throws -> Any? {
        try await IASDK.setUserDeliveryAddress(nil)
        return nil
    }

    func presentLogs() async throws -> Any? {
        IASDK.QA.presentLogs()
        return nil
    }

    func getUserId() async throws -> Any? {
        try await IASDK.QA.getUserID()
    }

    func setUserBillingAddress(arguments: Any) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaSetUserAddressArguments.self, from: arguments)
        try await IASDK.setUserBillingAddress(arguments.mappedToSDK())
        return nil
    }

    func setUserDeliveryAddress(arguments: Any) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaSetUserAddressArguments.self, from: arguments)
        try await IASDK.setUserDeliveryAddress(arguments.mappedToSDK())
        return nil
    }
}

extension IASDKInitializationState {
    /// The initialization state as Dart's `IaSdkInitializationState` names it, matching the Android SDK's states.
    /// It follows the initialization only, so prerequisites that run later don't make it flip back to initializing.
    var flutterName: String {
        switch initializationResult {
        case .success: "initialized"
        // A retry keeps the earlier failure until it finishes.
        case .failure: isInProgress ? "initializing" : "error"
        case nil: isInProgress ? "initializing" : "uninitialized"
        }
    }
}
