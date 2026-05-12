import Flutter
import UIKit
import IACore
import IACardLink

@MainActor
class LaunchHandler {
    private var savedConfiguration: CardLinkConfiguration?
    private var savedSdkApiKey: String?
    private let eventSender: CardLinkEventSender

    init(eventSender: CardLinkEventSender) {
        self.eventSender = eventSender
    }

    func handle(args: [String: Any], result: @escaping FlutterResult) {
        setupStyleAndConfiguration(args: args)

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
            guard let rootViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not find root view controller", details: nil))
                return
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
              let apiKey = savedSdkApiKey,
              let rootViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }

        CardLink.legacyAuthenticationKey = .init(value: apiKey)
        CardLink.finish { [weak self] in
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

    private func setupStyleAndConfiguration(args: [String: Any]) {
        let primaryColor = UIColor(argb: args["primaryColor"] as? Int)
        let buttonsColor = UIColor(argb: args["buttonsColor"] as? Int)
        let textLinkColor = UIColor(argb: args["textLinkColor"] as? Int)
        let bottomNavigationColor = UIColor(argb: args["bottomNavigationColor"] as? Int)

        let configuration = CardLinkConfiguration(args: args)
        self.savedConfiguration = configuration
        self.savedSdkApiKey = args["sdkApiKey"] as? String

        let style = CardLinkStyle(
            primaryColor: primaryColor,
            buttonsColor: buttonsColor,
            textLinkColor: textLinkColor,
            bottomNavigationColor: bottomNavigationColor
        )

        CardLink.legacyStyle = style
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
            CardLink.finish()
        case .prescriptionsRedeemed(let prescriptions):
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
            eventSender.sendFailedToInitializeEvent(error: error)
        case .trackEvent(let event):
            eventSender.sendAnalyticsEvent(event: event)
        case .addedPrescriptionsToCart(_):
            break
        case .reopenCardlink:
            reopenCardLink()
        @unknown default:
            break
        }
    }
}
