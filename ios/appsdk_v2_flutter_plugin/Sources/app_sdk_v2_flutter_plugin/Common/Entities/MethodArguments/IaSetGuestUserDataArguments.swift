//
//  IaSetGuestUserDataArguments.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 22.12.2025..
//

import Foundation
import IACore

/// Arguments for setting guest user data.
struct IaSetGuestUserDataArguments: Decodable {
    let salutation: IaSalutation
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumberCountryCode: String
    let phoneNumberWithoutCountryCode: String

    func mappedToSDK() -> IAUserData {
        IAUserData(
            salutation: salutation.mappedToSDK(),
            firstName: firstName,
            lastName: lastName,
            countryCode: phoneNumberCountryCode,
            phoneNumber: phoneNumberWithoutCountryCode,
            email: email
        )
    }
}

enum IaSalutation: String, Decodable {
    // @TODO: this is how flutter sends it, see if we can send english ids.
    case male = "herr"
    case female = "frau"
    case notSpecified = "keine angabe"
    case diverse = "diverse"

    /// Custom decoding is needed because we want case insensitive matching.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()

        guard let value = IaSalutation(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid salutation value: \(rawValue)"
            )
        }
        self = value
    }

    func mappedToSDK() -> IAUserSalutation {
        switch self {
        case .male: .male
        case .female: .female
        case .notSpecified: .notSpecified
        case .diverse: .diverse
        }
    }
}
