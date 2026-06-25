import Foundation
import Combine
import IACore
import IAIntegrations
import UIKit

@MainActor
final class IASDKWrapper {
    private let argumentDecoder = IaArgumentDecoder()

    func initialize(arguments: Any) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaInitSdkArguments.self, from: arguments)
        let initializationOptions = arguments.initialization.mappedToSDK()
        
        // Configuration
        IASDK.setEnvironment(arguments.serverEnvironment.mappedToSDK())
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

        // @TODO: remove, just for testing
        IASDK.QA.setQAFeatures([.showTestPharmaciesOnApofinder])
        
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
    
    func launchRoute(arguments: Any) async throws -> Any? {
        let arguments = try argumentDecoder.decode(IaLaunchRouteArguments.self, from: arguments)
        let screen = try arguments.view.iaScreen()
        screen.present()
        return nil
    }
    
    func finishAllActivities(arguments: Any) async throws -> Any? {
        // @TODO: This will work for now but we will have to discuss how to best implement this.
        UIApplication.shared.rootViewController?.dismiss(animated: true)
        return nil
    }

    func transferSDKv1UserData() async throws -> Any? {
        await IASDK.transferSDKv1UserData()
        return nil
    }

    func isInitialized() async throws -> Any? {
        let state = IASDK.initializationState
        let summary = state.summary
        return summary == .initializationFinished || summary == .initializationAndPrerequisitesFinished
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

    func getPharmacyId() async throws -> Any? {
        guard let pharmacyId = IASDK.Pharmacy.getPharmacyID() else {
            return nil
        }
        return String(pharmacyId)
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
