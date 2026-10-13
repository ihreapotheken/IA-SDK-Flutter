import Flutter
import IACore
import IACardLink

@MainActor
class DeleteCardHandler {
    func handle(args: [String: Any], result: @escaping FlutterResult) {
        guard let userId = args["userId"] as? String else {
            result(FlutterError(code: "MISSING_USER_ID", message: "userId is required", details: nil))
            return
        }
        guard let cardName = args["cardName"] as? String else {
            result(FlutterError(code: "MISSING_CARD_NAME", message: "cardName is required", details: nil))
            return
        }

        // The SDK reports a card that isn't saved like a storage failure, so that's checked first. Like on Android,
        // deleting it then does nothing.
        if let savedCards = CardLink.getSavedCards(userId: userId), !savedCards.contains(where: { $0.name == cardName }) {
            result(nil)
            return
        }
        do {
            try CardLink.deleteCard(userId: userId, name: cardName)
            result(nil)
        } catch {
            result(FlutterError(code: "DELETE_CARD_ERROR", message: "\(error)", details: nil))
        }
    }
}
