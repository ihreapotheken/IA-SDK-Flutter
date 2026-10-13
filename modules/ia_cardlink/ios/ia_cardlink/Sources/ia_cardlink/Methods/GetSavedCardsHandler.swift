import Flutter
import IACore
import IACardLink

@MainActor
class GetSavedCardsHandler {
    func handle(args: [String: Any], result: @escaping FlutterResult) {
        let userId = args["userId"] as? String ?? ""
        // The SDK returns an empty list without saved cards and nil only when reading them failed.
        guard let cards = CardLink.getSavedCards(userId: userId) else {
            result(FlutterError(code: "STORAGE_ERROR", message: "Reading the saved cards failed", details: nil))
            return
        }

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
