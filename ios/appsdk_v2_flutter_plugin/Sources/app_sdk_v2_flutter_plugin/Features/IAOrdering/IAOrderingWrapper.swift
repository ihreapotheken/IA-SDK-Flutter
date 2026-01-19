import Foundation
import IACore
import IAIntegrations
import IAOrdering

@MainActor
final class IAOrderingWrapper {
    private let argumentDecoder = IaArgumentDecoder()
    
    func clearCart(arguments: Any) async throws -> Any? {
        try await IAOrderingSDK.deleteCart()
        return nil
    }
    
    func transferPrescriptions(arguments: Any) async throws -> Any? {
        let arguments = try IaTransferPrescriptionsArguments(from: arguments)
        let mapped = arguments.mappedToSDK()
        
        try await IAOrderingSDK.transferPrescriptions(
            images: mapped.images,
            pdfs: mapped.pdfs,
            codes: mapped.codes,
            orderID: mapped.orderId,
            showActivityIndicator: true,
            finishAction: .openCart
        )
        return nil
    }
}
