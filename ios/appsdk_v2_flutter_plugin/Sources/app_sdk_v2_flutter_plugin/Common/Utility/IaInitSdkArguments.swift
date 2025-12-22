import Foundation
import IACore

/// Arguments for initializing the IA SDK.
struct IaInitSdkArguments: Decodable {
    /// Key used to authenticate the client setup with the backend service.
    let accessKey: String
    
    /// Client identifier used to determine the pharmacy channel specification.
    let clientId: String
    
    /// Selected server environment specification.
    let serverEnvironment: IaEnvironment
    
    /// Whether to fetch theme configuration from remote server.
    let shouldFetchThemeFromRemote: Bool
    
    /// Footer configuration options.
    let footer: IaFooterConfiguration
    
    /// Initialization configuration options.
    let initialization: IaInitializationConfiguration
    
    /// Creates an instance from a JSON dictionary using JSONDecoder.
    /// - Parameter json: Dictionary containing the initialization arguments
    /// - Returns: A new IaInitSdkArguments instance, or nil if decoding fails
    static func fromJson(_ json: [String: Any]) -> IaInitSdkArguments? {
        return JSONDecoder().decode(IaInitSdkArguments.self, from: json)
    }
}

/// Configuration options for SDK footer buttons.
struct IaFooterConfiguration: Decodable {
    /// Whether to show the data processing button in the footer.
    let shouldShowDataProcessing: Bool

    /// Whether to show the app settings button in the footer.
    let shouldShowAppSettings: Bool

    /// Whether to show the imprint button in the footer.
    let shouldShowImprint: Bool
}

/// Configuration options for SDK prerequisites.
struct IaPrerequisitesConfiguration: Decodable {
    /// Whether to show a loading indicator during prerequisites.
    let shouldShowIndicator: Bool

    /// Whether the prerequisites flow can be cancelled.
    let isCancellable: Bool

    /// Whether to show animations during prerequisites flow.
    let isAnimated: Bool

    /// Whether to run legal documents flow if needed.
    let runLegalIfNeeded: Bool

    /// Whether to run onboarding flow if needed.
    let runOnboardingIfNeeded: Bool

    /// Whether to run pharmacy finder (Apofinder) flow if needed.
    let runApofinderIfNeeded: Bool
}

/// Configuration options for SDK initialization behavior.
struct IaInitializationConfiguration: Decodable {
    /// Whether to show a loading indicator during initialization.
    let shouldShowIndicator: Bool

    /// Prerequisites configuration options.
    let prerequisites: IaPrerequisitesConfiguration
}

enum IaEnvironment: String, Decodable {
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
