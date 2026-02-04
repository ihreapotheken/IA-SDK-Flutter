import Flutter
import IACore
import IACardLink

@MainActor
class CardLinkEventSender {
    private var methodChannel: FlutterMethodChannel?

    func setMethodChannel(_ channel: FlutterMethodChannel?) {
        self.methodChannel = channel
    }

    func sendConsentEvent(accepted: Bool, phoneNumber: String?) {
        let status = accepted ? "accepted" : "declined"
        methodChannel?.invokeMethod(
            "cardLinkConsentEvent",
            arguments: ["status": status]
        )
    }

    func sendSessionCreatedEvent(session: CardLinkOutputAction.CardLinkSession) {
        let sessionDict: [String: Any] = [
            "cardSessionId": session.cardSessionId,
            "sessionExpireTimestamp": session.sessionExpiresAt
        ]
        methodChannel?.invokeMethod(
            "cardLinkSessionCreated",
            arguments: ["session": sessionDict]
        )
    }

    func sendPrescriptionsRedeemedEvent(prescriptions: String) {
        methodChannel?.invokeMethod(
            "cardLinkPrescriptionsRedeemed",
            arguments: ["prescriptions": prescriptions]
        )
    }

    func sendEvent(_ event: CardLinkEventType) {
        methodChannel?.invokeMethod(
            "cardLinkEvent",
            arguments: ["event": event.rawValue]
        )
    }

    func sendCardSavedEvent(cards: [CardData]) {
        let formattedCards = cards.map { card in
            return [
                "id": card.id,
                "name": card.name,
                "canNumber": card.canNumber,
                "phoneNumber": card.phoneNumber
            ]
        }
        methodChannel?.invokeMethod(
            "cardLinkEvent",
            arguments: ["event": "cardSaved", "cards": formattedCards]
        )
    }

    func sendFailedToInitializeEvent(error: CardLinkOutputAction.InitializationError) {
        let reason: String
        switch error {
        case .missingAuthenticationKey:
            reason = "Missing authentication key."
        case .missingPharmacyID:
            reason = "Missing pharmacy ID."
        case .failedToAuthenticate:
            reason = "Failed to authenticate, please check your authentication key and bundle id."
        default:
            reason = "Unknown error"
        }
        methodChannel?.invokeMethod(
            "cardLinkEvent",
            arguments: [
                "event": "failedToInitialize",
                "errorMessage": "CardLink SDK failed to initialize: \(reason)"
            ]
        )
    }

    func sendAnalyticsEvent(event: String) {
        methodChannel?.invokeMethod(
            "cardLinkAnalyticsEvent",
            arguments: ["analyticEvent": event]
        )
    }
}
