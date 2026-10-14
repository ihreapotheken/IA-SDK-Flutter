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
        // The SDK expects the country code with a leading "+", like its default "+49", and reads it back that way.
        let countryCode = phoneNumberCountryCode.trimmingCharacters(in: .whitespaces)
        return IAUserData(
            salutation: salutation.mappedToSDK(),
            firstName: firstName,
            lastName: lastName,
            countryCode: countryCode.hasPrefix("+") ? countryCode : "+" + countryCode,
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
        let rawValue = try container.decode(String.self).trimmingCharacters(in: .whitespaces).lowercased()

        // "Divers" is the label the Android AppSDK uses, accept it so the same Dart value works on both platforms.
        if rawValue == "divers" {
            self = .diverse
            return
        }

        // Unknown values are stored as "not specified", like on Android, instead of losing the user data.
        self = IaSalutation(rawValue: rawValue) ?? .notSpecified
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
