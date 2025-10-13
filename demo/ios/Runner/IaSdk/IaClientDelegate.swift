import IACore

internal class IaClientDelegate : SDKDelegate, OrderingDelegate {
  func pharmacyHeaderWillOpenPharmacyScreen(pharmacy: IACore.Pharmacy) -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func startScreenWillOpenProductSearchScreen() -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func startScreenWillOpenDiscoverOffersScreen() -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func hostAppShouldOpenPrivacyPolicy() {
  }
  
  func willOpenApofinder() -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func apofinderDidChangePharmacy(_ pharmacy: IACore.Pharmacy, isFromPrerequisites: Bool) {
  }
  
  func orderingWillOpenProductSearchScreen() -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func orderingWillOpenPharmacyScreen(pharmacy: IACore.Pharmacy) -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func cartButtonWillOpenCartScreen() -> IACore.WillOpenResult {
    return .notHandled
  }
}

