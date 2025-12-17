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
    
    let cartItemCountListener: CurrentValueSubject<Int, Never>
    
    init(
        channel: FlutterMethodChannel,
        cartItemCountListener: CurrentValueSubject<Int, Never>
    ) {
        self.channel = channel
        self.cartItemCountListener = cartItemCountListener
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
                "didFinishOrder",
                arguments: [
                    "orderCode": order.orderCode,
                    "clientOrderID": order.clientOrderID,
                ],
            )
        }
    }
        
    func orderingDidUpdateCart(cartState: IACartState) {
        // Update cart item count listener
        if let cartItemCount = cartState.cartDetails?.totalAmountInCart {
            cartItemCountListener.value = cartItemCount
        }

        // @TODO: Check with android if we can just send json instead of sending dictionaries like this.
        // Convert cart state to dictionary
        var cartDetailsDict: [String: Any]? = nil
        if let cartDetails = cartState.cartDetails {
            let productsArray = cartDetails.products.map { product in
                return [
                    "pzn": product.pzn,
                    "amount": product.amount
                ]
            }

            cartDetailsDict = [
                "products": productsArray,
                "totalAmountInCart": cartDetails.totalAmountInCart
            ]
        }

        let arguments: [String: Any] = [
            "cartDetails": cartDetailsDict as Any,
            "clientOrderIDs": cartState.clientOrderIDs
        ]

        // Send to Flutter
        channel.invokeMethod(
            "didUpdateCart",
            arguments: arguments
        )
    }
}
