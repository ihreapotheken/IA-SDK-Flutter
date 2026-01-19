import Foundation

/// Arguments for setting the pharmacy ID.
struct IaSetPharmacyIdArguments: Decodable {
    /// The pharmacy identifier as a string.
    let pharmacyId: String
    
    /// Pharmacy ID as Int. Didn't use custom decoding because it is an overkill.
    var pharmacyIdInt: Int {
        get throws {
            guard let id = Int(pharmacyId) else {
                throw IaArgumentError.decodingArgumentFailed(description: "Failed to convert pharmacyId to Int")
            }
            return id
        }
    }
}
