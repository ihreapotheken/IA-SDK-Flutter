import Foundation

/// Errors that can occur during argument decoding.
enum IaArgumentError: Error {
    /// Thrown when arguments sent from flutter are not dictionary [String: Any].
    case invalidInputArguments
    /// When some parameters fails to decode, this is used only for special cases (e.g. when trying to convert pharmacy ID string to int).
    case decodingArgumentFailed(description: String)
    /// Decoding json into Swift object failed.
    case decodingFailed(Error)
    /// Failed to convert input arguments to JSON.
    case jsonSerializationFailed

    var localizedDescription: String {
        switch self {
        case .invalidInputArguments:
            return "Arguments must be of type [String: Any]"
        case let .decodingArgumentFailed(description):
            return "Failed to decode argument: \(description)"
        case .jsonSerializationFailed:
            return "Failed to serialize arguments to JSON data. Numbers must be finite."
        case .decodingFailed(let error):
            return "Failed to decode arguments: \(Self.describe(error))"
        }
    }

    /// Names the argument that failed, which `DecodingError.localizedDescription` leaves out.
    private static func describe(_ error: Error) -> String {
        guard let decodingError = error as? DecodingError else { return error.localizedDescription }
        func path(_ codingPath: [CodingKey]) -> String {
            codingPath.isEmpty ? "arguments" : codingPath.map { $0.intValue.map(String.init) ?? $0.stringValue }.joined(separator: ".")
        }
        switch decodingError {
        case let .keyNotFound(key, context):
            return "missing value for \(path(context.codingPath + [key]))"
        case let .valueNotFound(type, context):
            return "missing \(type) value for \(path(context.codingPath))"
        case let .typeMismatch(type, context):
            return "expected \(type) for \(path(context.codingPath))"
        case let .dataCorrupted(context):
            return "invalid value for \(path(context.codingPath)): \(context.debugDescription)"
        @unknown default:
            return decodingError.localizedDescription
        }
    }
}
