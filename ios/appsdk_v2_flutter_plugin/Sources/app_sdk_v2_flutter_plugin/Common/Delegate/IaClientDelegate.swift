import Foundation
import IACore
import Combine
import Flutter

class IaClientDelegate: SDKDelegate {
    let channel: FlutterMethodChannel
    
    init(
        channel: FlutterMethodChannel,
    ) {
        self.channel = channel
    }
    
    func sdkWillNavigateToTarget(_ navigationTarget: IANavigationTarget, decisionHandler: @escaping (HandlingDecision) -> Void) {
        // Convert navigation target to string
        let navigationTargetString: String
        switch navigationTarget {
        case .cart:
            navigationTargetString = "cart"
        case .pharmacyDetails:
            navigationTargetString = "pharmacyDetails"
        case .thankYou:
            navigationTargetString = "thankYou"
        case .imprint:
            navigationTargetString = "imprint"
        case .hostAppPrivacyPolicy:
            navigationTargetString = "hostAppPrivacyPolicy"
        case .apofinder:
            navigationTargetString = "apofinder"
        }
        
        // Call Flutter callback and wait for response
        channel.invokeMethod(
            "sdkWillNavigateToTarget",
            arguments: ["navigationTarget": navigationTargetString]
        ) { result in
            // Parse the response
            guard let decisionString = result as? String else {
                // If no valid response, perform default
                decisionHandler(.performDefault)
                return
            }
            
            // Convert string to HandlingDecision
            let decision: HandlingDecision
            switch decisionString {
            case "handled":
                decision = .handled
            case "performDefault":
                decision = .performDefault
            default:
                decision = .performDefault
            }
            
            decisionHandler(decision)
        }
    }
    
    func orderingDidFinishOrders(orders: [IAOrder]) {
        guard let orderCode = orders.first?.orderCode else { return }
        let clientOrderIDs = orders.compactMap(\.clientOrderID)
        
        channel.invokeMethod(
            "orderingDidFinishOrder",
            arguments: [
                "orderCode": orderCode,
                "clientOrderIDs": clientOrderIDs,
            ],
        )
    }
    
    func orderingDidUpdateCart(cartState: IACartState) {
        // Extract totalAmountInCart from cartDetails, default to 0 if nil
        let totalAmountInCart = cartState.cartDetails?.totalAmountInCart ?? 0
        
        let arguments: [String: Any] = [
            "totalAmountInCart": totalAmountInCart,
            "clientOrderIDs": cartState.clientOrderIDs
        ]
        
        // Send to Flutter
        channel.invokeMethod(
            "orderingDidUpdateCart",
            arguments: arguments
        )
    }
}
