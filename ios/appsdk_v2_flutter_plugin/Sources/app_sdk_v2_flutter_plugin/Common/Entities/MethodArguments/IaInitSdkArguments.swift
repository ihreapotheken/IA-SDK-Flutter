import Foundation
import IACore
import SwiftUI

/// Arguments for initializing the IA SDK.
struct IaInitSdkArguments: Decodable {
    let accessKey: String
    let clientId: String
    let serverEnvironment: IaEnvironmentArguments
    let shouldFetchThemeFromRemote: Bool
    let footer: IaFooterConfigurationArguments
    let initialization: IaInitializationConfigurationArguments
    let uiConfiguration: IaUIConfigurationArguments
}

/// Configuration options for SDK UI appearance.
struct IaUIConfigurationArguments: Decodable {
    let supportsLiquidGlass: Bool
    let shouldShowMascotIllustrations: Bool
    let header: IaHeaderConfigurationArguments
    let primaryButton: IaButtonConfigurationArguments
    let secondaryButton: IaButtonConfigurationArguments

    func mappedToSDK() -> SDKConfiguration.UIConfiguration {
        var config = SDKConfiguration.UIConfiguration()
        config.supportsLiquidGlass = supportsLiquidGlass
        config.shouldShowMascotIllustrations = shouldShowMascotIllustrations
        header.apply(to: &config.header)
        primaryButton.apply(to: &config.primaryButton)
        secondaryButton.apply(to: &config.secondaryButton)
        return config
    }
}

// @TODO: IAHeaderConfiguration, IAPrimaryButtonConfiguration and IASecondaryButtonConfiguration
// don't have public initializers. Once public inits are added in IA-SDK-Dev-iOS,
// refactor apply(to:) methods below to mappedToSDK() returning new instances instead.

/// Configuration options for SDK header appearance.
struct IaHeaderConfigurationArguments: Decodable {
    let style: String
    let primaryColor: Int?
    let secondaryColor: Int?

    func apply(to header: inout IAHeaderConfiguration) {
        header.style = style == "monotone" ? .monotone : .duotone
        header.primaryColor = primaryColor.map { Color(argb: $0) }
        header.secondaryColor = secondaryColor.map { Color(argb: $0) }
    }
}

/// Configuration options for SDK button appearance.
struct IaButtonConfigurationArguments: Decodable {
    let backgroundColor: Int?
    let backgroundDisabledColor: Int?
    let textColor: Int?
    let textDisabledColor: Int?
    let borderColor: Int?
    let borderDisabledColor: Int?
    let borderWidth: CGFloat?
    let borderRadius: CGFloat?

    func apply(to button: inout IAPrimaryButtonConfiguration) {
        button.backgroundColor = backgroundColor.map { Color(argb: $0) }
        button.backgroundDisabledColor = backgroundDisabledColor.map { Color(argb: $0) }
        button.textColor = textColor.map { Color(argb: $0) }
        button.textDisabledColor = textDisabledColor.map { Color(argb: $0) }
        button.borderColor = borderColor.map { Color(argb: $0) }
        button.borderDisabledColor = borderDisabledColor.map { Color(argb: $0) }
        button.borderWidth = borderWidth
        button.borderRadius = borderRadius
    }

    func apply(to button: inout IASecondaryButtonConfiguration) {
        button.backgroundColor = backgroundColor.map { Color(argb: $0) }
        button.backgroundDisabledColor = backgroundDisabledColor.map { Color(argb: $0) }
        button.textColor = textColor.map { Color(argb: $0) }
        button.textDisabledColor = textDisabledColor.map { Color(argb: $0) }
        button.borderColor = borderColor.map { Color(argb: $0) }
        button.borderDisabledColor = borderDisabledColor.map { Color(argb: $0) }
        button.borderWidth = borderWidth
        button.borderRadius = borderRadius
    }
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
    let channelId: Int?
    let shouldShowIndicator: Bool
    let prerequisites: IaPrerequisitesConfigurationArguments
    
    func mappedToSDK() -> IASDKInitializationOptions {
        .init(
            shouldShowIndicator: shouldShowIndicator,
            prerequisitesOptions: prerequisites.mappedToSDK(),
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
