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
            return "Failed to serialize arguments to JSON data"
        case .decodingFailed(let error):
            return "Failed to decode arguments: \(error.localizedDescription)"
        }
    }
}
