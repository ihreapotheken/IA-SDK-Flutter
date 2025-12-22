//
//  JSONDecoder+.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 22.12.2025..
//

import Foundation

/// Extension to JSONDecoder for decoding from dictionary.
extension JSONDecoder {
    /// Decodes a value from a dictionary by first converting it to JSON data.
    /// - Parameters:
    ///   - type: The type to decode
    ///   - dictionary: The dictionary containing the data to decode
    /// - Returns: The decoded value, or nil if decoding fails
    func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) -> T? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary) else {
            return nil
        }
        return try? decode(type, from: jsonData)
    }
}
