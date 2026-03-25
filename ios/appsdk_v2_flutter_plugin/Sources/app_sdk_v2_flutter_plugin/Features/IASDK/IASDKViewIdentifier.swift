import Foundation
import IACore
import IAIntegrations

enum IASDKViewIdentifier: String, CaseIterable {
    /**
     * Start screen displaying main app content.
     */
    case startScreen = "startScreen"
        
    /**
     * Product search screen.
     */
    case productSearchScreen  = "searchScreen"  // Different ID so it works on android

    /**
     * Cart screen from IAOrdering module.
     */
    case cartScreen = "cartScreen"

    /**
     * Pharmacy details screen from IAPharmacy module.
     */
    case pharmacyDetails = "pharmacyScreen"

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
        }
    }
}
