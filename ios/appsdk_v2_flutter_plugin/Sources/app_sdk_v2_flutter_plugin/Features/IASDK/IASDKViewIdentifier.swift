//
//  File.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 29.12.2025..
//

import Foundation
import IACore
import IAIntegrations
import IAOverTheCounter
import IAOrdering

enum IASDKViewIdentifier: String, CaseIterable {
    /**
     * Start screen displaying main app content.
     */
    case startScreen
    
    /**
     * Cart screen displaying order overview.
     */
    case cartScreen
    
    /**
     * Product search screen.
     */
    case productSearchScreen
            
    /**
     * Visual interface representation.
     */
    func iaScreen() -> any IAScreen {
        switch self {
        case IASDKViewIdentifier.startScreen:
            IAStartScreen()
            
        case IASDKViewIdentifier.cartScreen:
            IACartScreen()
            
        case IASDKViewIdentifier.productSearchScreen:
            IAProductSearchScreen()
        }
    }
}
