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
            print(">>> Got result: \(result)")
            
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
        print(">>> orderingDidFinishOrders \(orders.map { $0.clientOrderID })")
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
        
    // @TODO delegate
    func orderingDidUpdateCart(cartState: IACartState) {
        if let cartItemCount = cartState.cartDetails?.totalAmountInCart {
            cartItemCountListener.value = cartItemCount
        }
    }
}
