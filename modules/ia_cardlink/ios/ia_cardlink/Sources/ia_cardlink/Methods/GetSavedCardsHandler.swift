import Flutter
import IACore
import IACardLink

@MainActor
class GetSavedCardsHandler {
    func handle(args: [String: Any], result: @escaping FlutterResult) {
        let userId = args["userId"] as? String ?? ""
        let cards = CardLink.getSavedCards(userId: userId)

        do {
            let jsonData = try JSONEncoder().encode(cards)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                result(jsonString)
            } else {
                result(FlutterError(code: "JSON_ERROR", message: "Could not encode JSON string", details: nil))
            }
        } catch {
            result(FlutterError(code: "ENCODING_ERROR", message: "Error encoding cards to JSON", details: error.localizedDescription))
        }
    }
}
