import Foundation
import IACore

/// Arguments for setting the user's billing or delivery address.
struct IaSetUserAddressArguments: Decodable {
    let firstName: String
    let lastName: String
    let additionalInfo: String?
    let street: String
    let houseNumber: String
    let zipCode: String
    let city: String
    let salutation: IaSalutation?
    let phoneNumberCountryCode: Int?
    let phoneNumberWithoutCountryCode: String?

    func mappedToSDK() -> IAUserAddress {
        var phoneNumber: IAPhoneNumber?
        if let countryCode = phoneNumberCountryCode,
           let number = phoneNumberWithoutCountryCode {
            phoneNumber = IAPhoneNumber(countryCode: countryCode, phoneNumber: number)
        }

        return IAUserAddress(
            firstName: firstName,
            lastName: lastName,
            additionalInfo: additionalInfo,
            street: street,
            houseNumber: houseNumber,
            zipCode: zipCode,
            city: city,
            salutation: salutation?.mappedToSDK(),
            phoneNumber: phoneNumber
        )
    }
}
