import Foundation
import IACore

@MainActor
final class IAOrderingWrapper {
    private let argumentDecoder = IaArgumentDecoder()
    
    func clearCart(arguments: Any) async throws -> Any? {
        try await IASDK.ordering.deleteCart()
        return nil
    }
    
    func getCartDetails() async throws -> Any? {
        let cartDetails = try await IASDK.ordering.getCartDetails(
            allowCached: true, throwIfNil: false, shouldEmit: false
        )
        guard let cartDetails else { return nil }
        let products = cartDetails.products.map { product in
            ["pzn": product.pzn, "amount": product.amount] as [String: Any]
        }
        return [
            "totalAmountInCart": cartDetails.totalAmountInCart,
            "products": products,
        ] as [String: Any]
    }

    func deleteOrderHistory() async throws -> Any? {
        try await IASDK.ordering.deleteOrderHistory()
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
