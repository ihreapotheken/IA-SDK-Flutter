import Foundation

/// Decoder for Flutter method call arguments.
class IaArgumentDecoder {
    private let jsonDecoder: JSONDecoder

    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }

    /// Decodes arguments from Flutter method call into a Decodable type.
    /// - Parameters:
    ///   - arguments: The arguments object from Flutter (expected to be [String: Any])
    ///   - type: The type to decode to
    /// - Returns: Decoded object of type T
    /// - Throws: IaArgumentError if decoding fails
    func decode<T: Decodable>(_ type: T.Type, from arguments: Any) throws -> T {
        guard let dictionary = arguments as? [String: Any] else {
            throw IaArgumentError.invalidInputArguments
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary) else {
            throw IaArgumentError.jsonSerializationFailed
        }

        do {
            return try jsonDecoder.decode(type, from: jsonData)
        } catch {
            throw IaArgumentError.decodingFailed(error)
        }
    }
}
