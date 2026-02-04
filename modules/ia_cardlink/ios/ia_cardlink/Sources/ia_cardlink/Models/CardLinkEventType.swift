import Foundation

enum CardLinkEventType: String {
    case willExit = "willExitCardlink"
    case willStartScanning = "willStartScanning"
    case failedToInitialize = "cardlinkFailedToInitialize"
    case goToCart = "goToCart"
    case openTermsAndConditions = "openTermsAndConditions"
    case cardSaved = "saveCard"
}
