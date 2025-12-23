//
//  IaArgumentError.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 22.12.2025..
//

import Foundation

/// Errors that can occur during argument decoding.
enum IaArgumentError: Error {
    case invalidInputArguments
    case decodingArgumentFailed(description: String)
    case jsonSerializationFailed
    case decodingFailed(Error)

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
