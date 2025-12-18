//
//  IaClientDelegate.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 17.12.2025..
//

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
    
    func sdkShouldOverrideRoute(_ routeOverride: IARouteOverride, decisionHandler: @escaping (HandlingDecision) -> Void) {
        // Convert route override to string
        let routeOverrideString: String
        switch routeOverride {
        case .cart:
            routeOverrideString = "cart"
        case .pharmacyDetails:
            routeOverrideString = "pharmacyDetails"
        case .thankYou:
            routeOverrideString = "thankYou"
        case .imprint:
            routeOverrideString = "imprint"
        case .hostAppPrivacyPolicy:
            routeOverrideString = "hostAppPrivacyPolicy"
        case .apofinder:
            routeOverrideString = "apofinder"
        }
        
        // Call Flutter callback and wait for response
        channel.invokeMethod(
            "shouldOverrideRoute",
            arguments: ["routeOverride": routeOverrideString]
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
        if let order = orders.first {
            channel.invokeMethod(
                "orderingDidFinishOrders",
                arguments: [
                    "orderCode": order.orderCode,
                    "clientOrderID": order.clientOrderID,
                ],
            )
        }
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
