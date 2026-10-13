import SwiftUI

import Flutter

import IACore
import IACardLink

@MainActor
class LaunchHandler {
    private var savedConfiguration: CardLinkConfiguration?
    private var savedSdkApiKey: String?
    private let eventSender: CardLinkEventSender
    /// SDK-wide palette from before a launch with colors, restored when CardLink closes.
    private var paletteBeforeLaunch: IAColorPalette?

    init(eventSender: CardLinkEventSender) {
        self.eventSender = eventSender
    }

    func handle(args: [String: Any], result: @escaping FlutterResult) {
        setupConfigurationAndStyle(args: args)

        guard let configuration = savedConfiguration else {
            result(FlutterError(code: "CONFIGURATION_ERROR", message: "Failed to create configuration", details: nil))
            return
        }

        guard let sdkApiKey = args["sdkApiKey"] as? String else {
            result(FlutterError(code: "MISSING_API_KEY", message: "SDK API key is required", details: nil))
            return
        }

        let flowTypeString = args["flowType"] as? String ?? "launchCardLinkSdk"
        let flowType: CardlinkFlowType = flowTypeString == "launchCardLinkCards" ? .startSavedCards : .startCardlink

        DispatchQueue.main.async { [weak self] in
            guard let rootViewController = Self.topPresentedViewController() else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller", details: nil))
                return
            }

            // @TODO high: This is just for core app, remove it after it starts using SDK initialization.
            if let environmentString = args["environment"] as? String {
                if environmentString == "PRODUCTION" {
                    IASDK.setEnvironment(.prod)
                } else if environmentString == "DEBUG" {
                    IASDK.setEnvironment(.staging)
                }
            }
            CardLink.legacyAuthenticationKey = .init(value: sdkApiKey)
            CardLink.start(
                type: flowType,
                forcePresent: false,
                on: rootViewController,
                configuration: configuration,
                onOutputAction: { [weak self] action in
                    self?.handleOutputAction(action)
                }
            )
            result(nil)
        }
    }

    func reopenCardLink() {
        guard let config = savedConfiguration,
              let apiKey = savedSdkApiKey else {
            return
        }

        CardLink.legacyAuthenticationKey = .init(value: apiKey)
        Self.finishCardLink { [weak self] in
            // Looked up after CardLink is dismissed, so it isn't CardLink's own view controller.
            guard let rootViewController = Self.topPresentedViewController() else { return }
            CardLink.start(
                type: .startCardlink,
                forcePresent: false,
                on: rootViewController,
                configuration: config,
                onOutputAction: { [weak self] action in
                    self?.handleOutputAction(action)
                }
            )
        }
    }


    /// Closes CardLink, then replies.
    func finish(result: @escaping FlutterResult) {
        Self.finishCardLink { [weak self] in
            self?.restorePalette()
            result(nil)
        }
    }

    /// The SDK only calls the completion of `CardLink.finish` after closing a shown CardLink, so it's called here
    /// directly when none is shown, for example after `finishAllActivities`.
    private static func finishCardLink(completion: @escaping () -> Void) {
        guard isCardLinkShown() else {
            CardLink.finish()
            completion()
            return
        }
        CardLink.finish(completion: completion)
    }

    /// Whether a CardLink screen is presented or pushed, which the SDK does depending on the view controller it's
    /// started on.
    private static func isCardLinkShown() -> Bool {
        var viewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
        while let current = viewController {
            let stack = [current] + ((current as? UINavigationController)?.viewControllers ?? [])
            if stack.contains(where: { String(reflecting: type(of: $0)).hasPrefix("IACardLink.") }) {
                return true
            }
            viewController = current.presentedViewController
        }
        return false
    }

    private func restorePalette() {
        guard let paletteBeforeLaunch else { return }
        Color.ia = paletteBeforeLaunch
        self.paletteBeforeLaunch = nil
    }

    /// The view controller CardLink is presented on. A view controller that already presents one can't present
    /// another, so this is the top-most presented one, for example an SDK screen shown on top of the app.
    private static func topPresentedViewController() -> UIViewController? {
        var viewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
        while let presented = viewController?.presentedViewController, !presented.isBeingDismissed {
            viewController = presented
        }
        return viewController
    }

    private func setupConfigurationAndStyle(args: [String: Any]) {
        let configuration = CardLinkConfiguration(args: args)
        self.savedConfiguration = configuration
        self.savedSdkApiKey = args["sdkApiKey"] as? String

        // Without a value the SDK-wide setting from initialize is kept.
        if let supportsLiquidGlass = args["supportsLiquidGlass"] as? Bool {
            IASDK.configuration.uiConfiguration.supportsLiquidGlass = supportsLiquidGlass
        }
        
        // @TODO: coreAppLogFileURL is used only by Core app. This should be refactored so IASDK.configuration can be setup separately from flutter, not when launching cardlink.
        if let coreAppLogFileURL = args["coreAppLogFileURL"] as? String, !coreAppLogFileURL.isEmpty {
            IASDK.configuration.hostAppLogFileURL = URL(fileURLWithPath: coreAppLogFileURL);
        }
        // @TODO: This should also be refactored, api key should not be passed in CardLink.launch. Same as above, refactor so IASDK.configuration.apiKey can be setup separately.
        if let sdkApiKey = args["sdkApiKey"] as? String, !sdkApiKey.isEmpty, IASDK.configuration.apiKey.isEmpty {
            IASDK.configuration.apiKey = sdkApiKey
        }

        // @TODO: This should also be refactored, api key should not be passed in CardLink.launch. Same as above, refactor so IASDK.configuration.apiKey can be setup separately.
        if let appID = args["appId"] as? String, !appID.isEmpty {
            IASDK.configuration.appStoreID = appID
        }

        let primaryColor = UIColor(argb: args["primaryColor"] as? Int)
        let buttonsColor = UIColor(argb: args["buttonsColor"] as? Int)
        let textLinkColor = UIColor(argb: args["textLinkColor"] as? Int)
        let bottomNavigationColor = UIColor(argb: args["bottomNavigationColor"] as? Int)

        // CardLink uses the SDK-wide palette, so it's only replaced when colors are passed, and restored when
        // CardLink closes. Palette colors that aren't passed use the SDK defaults meanwhile.
        guard primaryColor != nil || buttonsColor != nil || textLinkColor != nil || bottomNavigationColor != nil else {
            return
        }
        if paletteBeforeLaunch == nil {
            paletteBeforeLaunch = Color.ia
        }
        Color.ia = .init(
            primary: primaryColor.map { .init($0) },
            button: buttonsColor.map { .init($0) },
            link: textLinkColor.map { .init($0) },
            bottomNavigation: bottomNavigationColor.map { .init($0) }
        )
    }

    /// Reports an action of a CardLink flow the SDK started itself, for example from the redeem prescription screen.
    /// The SDK handles those flows, including their navigation, so navigation events aren't sent: a host following the
    /// docs would otherwise navigate as well.
    func handleSdkFlowOutputAction(_ action: CardLinkOutputAction) {
        switch action {
        case .backButtonPressed, .goToCart, .openTermsAndConditions, .reopenCardlink:
            break
        case .addedPrescriptionsToCart(let prescriptions):
            eventSender.sendPrescriptionsRedeemedEvent(prescriptions: Self.prescriptionsJSON(prescriptions))
        default:
            handleOutputAction(action)
        }
    }

    /// Prescriptions CardLink added to the cart itself, in the format of `.prescriptionsRedeemed`, which also
    /// includes a token the SDK doesn't pass here.
    private static func prescriptionsJSON(_ prescriptions: [EPrescriptionData]) -> String {
        struct AddedPrescription: Encodable {
            let taskId: String?
            let accessCode: String?
            let ePrescription: CardLinkEPrescription?
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let addedPrescriptions = prescriptions.map {
            AddedPrescription(taskId: $0.taskId, accessCode: $0.accessCode, ePrescription: $0.cardLinkEPrescription)
        }
        guard let data = try? encoder.encode(addedPrescriptions) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    private func handleOutputAction(_ action: CardLinkOutputAction) {
        switch action {
        case .consentAccepted(let phoneNumber):
            eventSender.sendConsentEvent(accepted: true, phoneNumber: phoneNumber)
        case .consentDeclined:
            eventSender.sendConsentEvent(accepted: false, phoneNumber: nil)
        case .sessionCreated(let session):
            eventSender.sendSessionCreatedEvent(session: session)
        case .backButtonPressed:
            eventSender.sendEvent(.willExit)
            Self.finishCardLink { [weak self] in
                self?.restorePalette()
            }
        case .prescriptionsRedeemed(let prescriptions):
            // The SDK sends .backButtonPressed next, which closes CardLink.
            eventSender.sendPrescriptionsRedeemedEvent(prescriptions: prescriptions)
        case .goToCart:
            eventSender.sendEvent(.goToCart)
        case .openTermsAndConditions:
            eventSender.sendEvent(.openTermsAndConditions)
        case .cardsSaved(let cards):
            eventSender.sendCardSavedEvent(cards: cards)
        case .willStartScanning:
            eventSender.sendEvent(.willStartScanning)
        case .failedToInitialize(let error):
            // CardLink isn't shown then.
            eventSender.sendFailedToInitializeEvent(error: error)
            restorePalette()
        case .trackEvent(let event):
            eventSender.sendAnalyticsEvent(event: event)
        case .addedPrescriptionsToCart(let prescriptions):
            // With the uploadPrescriptions finish action the SDK closes CardLink itself and sends only this action.
            eventSender.sendPrescriptionsRedeemedEvent(prescriptions: Self.prescriptionsJSON(prescriptions))
            eventSender.sendEvent(.willExit)
            restorePalette()
        case .reopenCardlink:
            reopenCardLink()
        @unknown default:
            break
        }
    }
}
