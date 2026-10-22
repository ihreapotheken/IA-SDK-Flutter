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
    let isPickupLockerAndCourierShippingEnabled: Bool?
    let appStoreId: String?
    let qaConfiguration: IaQaConfigurationArguments?
    let cardLink: IaCardLinkConfigurationArguments?
    let hostAppLogFilePath: String?
}

/// Configuration for CardLink flows the SDK starts itself.
struct IaCardLinkConfigurationArguments: Decodable {
    let isSaveCardEnabled: Bool?
    let userId: String?
    let phoneNumber: String?

    func applied(to configuration: CardLinkConfiguration) -> CardLinkConfiguration {
        var updated = configuration
        // userId can only be set through the initializer; the other values are changed in place, so the SDK's own
        // phone number isn't passed through the initializer's formatting again.
        if let userId, userId != configuration.userId {
            updated = CardLinkConfiguration(
                pharmacyId: configuration.pharmacyId,
                consentStatus: configuration.consentStatus,
                canCode: configuration.canCode,
                phoneNumber: configuration.phoneNumber,
                userId: userId,
                cardName: configuration.cardName,
                isSaveCardEnabled: configuration.isSaveCardEnabled,
                source: configuration.source,
                finishAction: configuration.finishAction
            )
        }
        // A saved card the user picked brings its own phone number, which its SMS code goes to.
        if let phoneNumber, configuration.canCode?.isEmpty ?? true {
            updated.setRawPhoneNumber(Self.formatted(phoneNumber: phoneNumber))
        }
        if let isSaveCardEnabled {
            updated.isSaveCardEnabled = isSaveCardEnabled
        }
        return updated
    }

    /// Formats the number like the `CardLinkConfiguration` initializer does for launched CardLink flows: only digits
    /// and a leading "+" are kept.
    private static func formatted(phoneNumber: String) -> String {
        let kept = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard let first = kept.first else { return kept }
        return String(first) + kept.dropFirst().filter { $0 != "+" }
    }
}

struct IaQaConfigurationArguments: Decodable {
    let showTestPharmaciesInApofinder: Bool
    let features: [String]?

    func mappedToSDK() -> Set<QAFeature> {
        var qaFeatures = Set((features ?? []).compactMap(Self.qaFeature(named:)))
        if showTestPharmaciesInApofinder {
            qaFeatures.insert(.showTestPharmaciesOnApofinder)
        }
        return qaFeatures
    }

    private static func qaFeature(named name: String) -> QAFeature? {
        switch name {
        case "easyLogsAccessInProduction": .easyLogsAccessInProduction
        case "forceRefreshCartScreenButton": .forceRefreshCartScreenButton
        case "pharmacyPCasesInfoButton": .pharmacyPCasesInfoButton
        case "longPressProductInfo": .longPressProductInfo
        case "sdkInfoInNavigationBar": .sdkInfoInNavigationBar
        case "showInteractionWithRealPharmacyWarning": .showInteractionWithRealPharmacyWarning
        case "showPharmacyIdInputOnApofinder": .showPharmacyIDInputOnApofinder
        case "imageViewerDebugDetails": .imageViewerDebugDetails
        case "showFailedScannedCodeInErrorMessage": .showFailedScannedCodeInErrorMessage
        case "enableFirstResponderLogging": .enableIAFirstResponderLogging
        case "showLabTestActivationCodeDetails": .showLabTestActivationCodeDetails
        default: nil
        }
    }
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
