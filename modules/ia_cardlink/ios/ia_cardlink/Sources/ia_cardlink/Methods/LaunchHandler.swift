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
    /// The palette the launch set. When the SDK replaced it meanwhile, with the remote theme of an initialization
    /// that finished, the SDK's palette is kept.
    private var paletteSetByLaunch: IAColorPalette?
    /// SDK-wide environment from before a launch with an environment, restored by a launch without one.
    private var environmentBeforeLaunch: EnvironmentID?
    /// The environment the launch set. When `IaSdk.initialize` set another one meanwhile, that one is kept.
    private var environmentSetByLaunch: EnvironmentID?
    /// Whether a CardLink flow launched from Flutter is shown, so its closing is reported once.
    private var isLaunchedFlowShown = false
    /// Whether the launched flow continues from the saved cards screen into the scan flow.
    private var isReopening = false

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
                self?.restorePalette()
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller", details: nil))
                return
            }

            // @TODO high: This is just for core app, remove it after it starts using SDK initialization.
            if let environmentString = args["environment"] as? String {
                let environment: EnvironmentID = environmentString == "PRODUCTION" ? .prod : .staging
                if self?.environmentBeforeLaunch == nil || IASDK.getEnvironment() != self?.environmentSetByLaunch {
                    self?.environmentBeforeLaunch = IASDK.getEnvironment()
                }
                IASDK.setEnvironment(environment)
                self?.environmentSetByLaunch = environment
            } else if let environmentBeforeLaunch = self?.environmentBeforeLaunch {
                // The environment IaSdk was initialized with, as on Android, unless initialize set it since.
                if IASDK.getEnvironment() == self?.environmentSetByLaunch {
                    IASDK.setEnvironment(environmentBeforeLaunch)
                }
                self?.environmentBeforeLaunch = nil
                self?.environmentSetByLaunch = nil
            }
            CardLink.legacyAuthenticationKey = .init(value: sdkApiKey)
            // Set before starting, as the SDK can report a failed start before `start` returns.
            self?.isLaunchedFlowShown = true
            self?.isReopening = false
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
            self?.isLaunchedFlowShown = true
            // The saved cards screen has closed; a failed start of the scan flow then ends the launched flow.
            self?.isReopening = true
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

    /// Keeps the environment `IaSdk.initialize` set for launches without an environment.
    func handleEnvironmentSetByInitialize() {
        environmentBeforeLaunch = nil
        environmentSetByLaunch = nil
    }

    /// Handles a launched CardLink flow that closed together with the SDK screen it was shown on, for example
    /// through `finishAllActivities`.
    func handleClosedWithSdkScreens() {
        Self.finishCardLink { [weak self] in
            self?.reportClosed()
        }
    }

    /// Reports `willExit` for a closed launched flow, once, and restores the palette.
    private func reportClosed() {
        restorePalette()
        guard isLaunchedFlowShown else { return }
        isLaunchedFlowShown = false
        eventSender.sendEvent(.willExit)
    }


    /// Closes CardLink, then replies.
    func finish(result: @escaping FlutterResult) {
        // Right after a launch CardLink signs in before it shows anything, and the SDK opens it afterwards anyway, so
        // its closing is only reported for a shown CardLink.
        let isShown = Self.isCardLinkShown()
        Self.finishCardLink { [weak self] in
            if isShown {
                self?.reportClosed()
            }
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
        if let paletteSetByLaunch, Self.isSamePalette(Color.ia, paletteSetByLaunch) {
            Color.ia = paletteBeforeLaunch
        }
        self.paletteBeforeLaunch = nil
        self.paletteSetByLaunch = nil
    }

    /// Compares the colors a launch sets, which tell its palette apart from the SDK's.
    private static func isSamePalette(_ palette: IAColorPalette, _ otherPalette: IAColorPalette) -> Bool {
        palette.primary == otherPalette.primary
            && palette.link == otherPalette.link
            && palette.bottomNavigation == otherPalette.bottomNavigation
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
        let palette = IAColorPalette(
            primary: primaryColor.map { .init($0) },
            button: buttonsColor.map { .init($0) },
            link: textLinkColor.map { .init($0) },
            bottomNavigation: bottomNavigationColor.map { .init($0) }
        )
        Color.ia = palette
        paletteSetByLaunch = palette
    }

    /// Reports an action of a CardLink flow the SDK started itself, for example from the redeem prescription screen.
    /// The SDK closes and reopens those flows itself, so their closing isn't reported. It only closes CardLink for the
    /// cart and terms actions, so those are reported for the host to act on.
    func handleSdkFlowOutputAction(_ action: CardLinkOutputAction) {
        switch action {
        case .backButtonPressed, .reopenCardlink:
            break
        case .goToCart:
            eventSender.sendEvent(.goToCart)
        case .openTermsAndConditions:
            eventSender.sendEvent(.openTermsAndConditions)
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
            Self.finishCardLink { [weak self] in
                self?.reportClosed()
            }
        case .prescriptionsRedeemed(let prescriptions):
            // The SDK sends .backButtonPressed next, which closes CardLink.
            eventSender.sendPrescriptionsRedeemedEvent(prescriptions: prescriptions)
        case .goToCart:
            eventSender.sendEvent(.goToCart)
        case .openTermsAndConditions:
            // The SDK has closed CardLink before this action, without .backButtonPressed.
            eventSender.sendEvent(.openTermsAndConditions)
            reportClosed()
        case .cardsSaved(let cards):
            eventSender.sendCardSavedEvent(cards: cards)
        case .willStartScanning:
            eventSender.sendEvent(.willStartScanning)
        case .failedToInitialize(let error):
            eventSender.sendFailedToInitializeEvent(error: error)
            if isReopening {
                // The saved cards screen that was shown has closed, like on Android.
                isReopening = false
                reportClosed()
            } else {
                // CardLink wasn't shown.
                isLaunchedFlowShown = false
                restorePalette()
            }
        case .trackEvent(let event):
            eventSender.sendAnalyticsEvent(event: event)
        case .addedPrescriptionsToCart(let prescriptions):
            // With the uploadPrescriptions finish action the SDK closes CardLink itself and sends only this action.
            eventSender.sendPrescriptionsRedeemedEvent(prescriptions: Self.prescriptionsJSON(prescriptions))
            reportClosed()
        case .reopenCardlink:
            reopenCardLink()
        @unknown default:
            break
        }
    }
}
