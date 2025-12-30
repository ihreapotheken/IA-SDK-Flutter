//
//  IASDKWrapper.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 29.12.2025..
//

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
        IASDK.configuration.shouldLoadRemoteStyleConfiguration = arguments.shouldFetchThemeFromRemote
        IASDK.configuration.footer.shouldShowAppSettings = arguments.footer.shouldShowAppSettings
        IASDK.configuration.footer.shouldShowDataProcessing = arguments.footer.shouldShowDataProcessing
        IASDK.configuration.footer.shouldShowImprint = arguments.footer.shouldShowImprint
        // @TODO, this is hardcoded, should be removed once backend starts returning proper channel IDs (IASDK-1927).
        IASDK.configuration.channelID = 2
        
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
        try await IASDK.deleteAllUserRelatedData()
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
    
}
