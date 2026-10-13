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
     * Apofinder (pharmacy finder) screen.
     */
    case apofinderScreen = "apofinderScreen"

    /**
     * Redeem prescription screen from IAPrescription module.
     */
    case redeemPrescription = "redeemPrescription"

    /**
     * Prescription photo scanner from IAPrescription module.
     */
    case prescriptionScanner = "prescriptionScanner"

    /**
     * E-prescription QR code scanner from IAPrescription module.
     */
    case ePrescriptionScanner = "ePrescriptionScanner"

    /**
     * Visual interface representation.
     */
    @MainActor
    func iaScreen(isCancellable: Bool = true, focusesOnAppear: Bool? = nil) -> any IAScreen {
        switch self {
        case IASDKViewIdentifier.startScreen:
            IAStartScreen()

        case IASDKViewIdentifier.productSearchScreen:
            if let focusesOnAppear {
                IAProductSearchScreen().focusesOnAppear(focusesOnAppear)
            } else {
                IAProductSearchScreen()
            }

        case IASDKViewIdentifier.cartScreen:
            IACartScreen()

        case IASDKViewIdentifier.pharmacyDetails:
            IAPharmacyScreen()

        case IASDKViewIdentifier.apofinderScreen:
            IAApofinderScreen(isCancellable: isCancellable, onFinish: { _ in })

        case IASDKViewIdentifier.redeemPrescription:
            IARedeemPrescriptionScreen()

        case IASDKViewIdentifier.prescriptionScanner:
            CameraControlledPrescriptionScannerScreen(type: .prescription)

        case IASDKViewIdentifier.ePrescriptionScanner:
            CameraControlledPrescriptionScannerScreen(type: .ePrescription)
        }
    }
}
