import Foundation
import IACore

/// Arguments for initializing the IA SDK.
struct IaInitSdkArguments: Decodable {
    let accessKey: String
    let clientId: String    
    let serverEnvironment: IaEnvironmentArguments
    let shouldFetchThemeFromRemote: Bool    
    let footer: IaFooterConfigurationArguments   
    let initialization: IaInitializationConfigurationArguments
}

/// Configuration options for SDK footer buttons.
struct IaFooterConfigurationArguments: Decodable {
    let shouldShowDataProcessing: Bool
    let shouldShowAppSettings: Bool    
    let shouldShowImprint: Bool
}

/// Configuration options for SDK prerequisites.
struct IaPrerequisitesConfigurationArguments: Decodable {
    let isCancellable: Bool
    let isAnimated: Bool
    let runLegalIfNeeded: Bool
    let runOnboardingIfNeeded: Bool
    let runApofinderIfNeeded: Bool
    
    func mappedToSDK() -> IASDKPrerequisitesOptions {
        .init(
            isCancellable: isCancellable, 
            isAnimated: isAnimated, 
            shouldRunLegal: runLegalIfNeeded, 
            shouldRunOnboarding: runOnboardingIfNeeded, 
            shouldRunApofinder: runApofinderIfNeeded
        )
    }
}

/// Configuration options for SDK initialization behavior.
struct IaInitializationConfigurationArguments: Decodable {
    let shouldShowIndicator: Bool
    let prerequisites: IaPrerequisitesConfigurationArguments
    
    func mappedToSDK() -> IASDKInitializationOptions {
        .init(
            shouldShowIndicator: shouldShowIndicator,
            prerequisitesOptions: prerequisites.mappedToSDK()
        )
    }
}

enum IaEnvironmentArguments: String, Decodable {
    case development = "development"
    case production = "production"
    case staging = "staging"
    
    func mappedToSDK() -> EnvironmentID {
        switch self {
        case .development: .dev
        case .production: .prod
        case .staging: .staging
        }
    }
}
