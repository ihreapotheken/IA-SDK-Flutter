//
//  IaSetPharmacyIdArguments.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 22.12.2025..
//

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
