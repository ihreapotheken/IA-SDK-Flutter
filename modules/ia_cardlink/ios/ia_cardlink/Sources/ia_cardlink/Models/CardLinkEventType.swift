import Foundation

enum CardLinkEventType: String {
    case willExit = "willExitCardlink"
    case willStartScanning = "willStartScanning"
    case failedToInitialize = "failedToInitialize"
    case goToCart = "goToCart"
    case openTermsAndConditions = "openTermsAndConditions"
    case cardSaved = "cardSaved"
}
