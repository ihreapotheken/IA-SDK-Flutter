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
import IAPharmacy
import IAPrescription

enum IASDKViewIdentifier: String, CaseIterable {
    /**
     * Start screen displaying main app content.
     */
    case startScreen
        
    /**
     * Product search screen.
     */
    case productSearchScreen

    /**
     * Cart screen from IAOrdering module.
     */
    case cartScreen

    /**
     * Pharmacy details screen from IAPharmacy module.
     */
    case pharmacyDetails

    /**
     * Prescription scanner screen from IAPrescription module.
     */
    case prescriptionScanner

    /**
     * E-Prescription scanner screen from IAPrescription module.
     */
    case ePrescriptionScanner

    /**
     * Visual interface representation.
     */
    func iaScreen() -> any IAScreen {
        switch self {
        case IASDKViewIdentifier.startScreen:
            IAStartScreen()

        case IASDKViewIdentifier.productSearchScreen:
            IAProductSearchScreen()

        case IASDKViewIdentifier.cartScreen:
            IACartScreen()

        case IASDKViewIdentifier.pharmacyDetails:
            IAPharmacyScreen()

        case IASDKViewIdentifier.prescriptionScanner:
            IAScannerScreen(type: .prescription)

        case IASDKViewIdentifier.ePrescriptionScanner:
            IAScannerScreen(type: .ePrescription)
        }
    }
}
