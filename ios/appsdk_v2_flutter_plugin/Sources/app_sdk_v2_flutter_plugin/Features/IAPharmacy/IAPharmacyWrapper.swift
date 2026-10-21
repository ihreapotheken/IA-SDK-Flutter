import Foundation
import IACore
import IAIntegrations

@MainActor
final class IAPharmacyWrapper {
    private let argumentDecoder = IaArgumentDecoder()   

    func getPharmacy(arguments: Any) async throws -> Any? {
        guard IASDK.Pharmacy.getPharmacyID() != nil else {
            return nil
        }
        let args = arguments as? [String: Any] ?? [:]
        let pharmacy = try await IASDK.Pharmacy.getPharmacy(allowCached: args["allowCached"] as? Bool ?? true)
        return pharmacy.flutterMap
    }
}
