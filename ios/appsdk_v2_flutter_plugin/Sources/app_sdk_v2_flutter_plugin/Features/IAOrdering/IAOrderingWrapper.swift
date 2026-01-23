import Foundation
import IACore

@MainActor
final class IAOrderingWrapper {
    private let argumentDecoder = IaArgumentDecoder()
    
    func clearCart(arguments: Any) async throws -> Any? {
        try await IASDK.ordering.deleteCart()
        return nil
    }
    
    func transferPrescriptions(arguments: Any) async throws -> Any? {
        let arguments = try IaTransferPrescriptionsArguments(from: arguments)
        let mapped = arguments.mappedToSDK()
        
        try await IASDK.ordering.transferPrescriptions(
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
