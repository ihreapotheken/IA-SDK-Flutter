/// Routes that the SDK may navigate to, which the host app can optionally override.
///
enum IaRouteOverride {
  /// SDK intends to open cart screen. This can be called from multiple points in the SDK.
  cart,

  /// SDK intends to open pharmacy details screen. This can be called from multiple points in the SDK.
  pharmacyDetails,

  /// Called after order and payment is processed and just before it will show thank you screen.
  /// Default behavior is to present SDK's thank you screen.
  /// If you return [IaHandlingDecision.handled], it will not present thank you screen.
  thankYou,

  /// "Impressum" button is tapped on the footer. If not handled it will open webview with content from CMS.
  imprint,

  /// "Datenverarbeitung" button is tapped on the footer. Nothing happens if not handled.
  hostAppPrivacyPolicy,

  /// SDK intends to open Apofinder from an internal flow (not prerequisites).
  /// Triggers include product details ("Apotheke wählen") and pharmacy screen (change pharmacy).
  apofinder;

  String get rawValue {
    return switch (this) {
      IaRouteOverride.cart => 'cart',
      IaRouteOverride.pharmacyDetails => 'pharmacyDetails',
      IaRouteOverride.thankYou => 'thankYou',
      IaRouteOverride.imprint => 'imprint',
      IaRouteOverride.hostAppPrivacyPolicy => 'hostAppPrivacyPolicy',
      IaRouteOverride.apofinder => 'apofinder',
    };
  }

  static IaRouteOverride? fromRawValue(String value) {
    return switch (value) {
      'cart' => IaRouteOverride.cart,
      'pharmacyDetails' => IaRouteOverride.pharmacyDetails,
      'thankYou' => IaRouteOverride.thankYou,
      'imprint' => IaRouteOverride.imprint,
      'hostAppPrivacyPolicy' => IaRouteOverride.hostAppPrivacyPolicy,
      'apofinder' => IaRouteOverride.apofinder,
      _ => null,
    };
  }
}
