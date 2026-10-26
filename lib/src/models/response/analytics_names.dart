part of '../../core.dart';

/// Event names as they appear in [IaSdkLoggedAnalyticsEvent.name].
///
/// New events are added over time, so code that switches over names needs a default case.
///
abstract final class IaSdkAnalyticsEventNames {
  /// An SDK screen appeared. Parameter: [IaSdkAnalyticsParameterNames.screenName].
  ///
  static const screenView = 'screen_view';

  /// A product went into the cart, or a cart product's quantity went up. No parameters.
  ///
  static const addToCart = 'add_to_cart';

  /// Products left the cart, or a cart product's quantity went down. No parameters.
  ///
  static const removeFromCart = 'remove_from_cart';

  /// An order was placed. Parameters: [IaSdkAnalyticsParameterNames.transactionId] and
  /// [IaSdkAnalyticsParameterNames.clientOrderId].
  ///
  static const purchase = 'purchase';

  /// A pharmacy was validated and set. Parameters: [IaSdkAnalyticsParameterNames.pharmacyId] and
  /// [IaSdkAnalyticsParameterNames.pharmacyName].
  ///
  static const pharmacySelected = 'pharmacy_selected';

  /// A prescription went into the cart. Parameters: [IaSdkAnalyticsParameterNames.prescriptionType] and
  /// [IaSdkAnalyticsParameterNames.method].
  ///
  static const prescriptionAdded = 'prescription_added';

  /// A prescription left the cart. Parameters: [IaSdkAnalyticsParameterNames.prescriptionType] and
  /// [IaSdkAnalyticsParameterNames.reason].
  ///
  static const prescriptionRemoved = 'prescription_removed';

  /// The user reached a feature that can't run on this device. Parameters: [IaSdkAnalyticsParameterNames.feature]
  /// and [IaSdkAnalyticsParameterNames.reason].
  ///
  static const featureUnavailable = 'feature_unavailable';
}

/// Parameter keys as they appear in [IaSdkLoggedAnalyticsEvent.parameters], with their allowed values.
///
abstract final class IaSdkAnalyticsParameterNames {
  /// One of [IaSdkAnalyticsScreenNames].
  ///
  static const screenName = 'screen_name';

  /// The pharmacy's order code.
  ///
  static const transactionId = 'transaction_id';

  /// The order id the host app passed to `transferPrescriptions`. Absent when it passed none.
  ///
  static const clientOrderId = 'client_order_id';

  /// Identifier of the selected pharmacy.
  ///
  static const pharmacyId = 'pharmacy_id';

  /// Name of the selected pharmacy.
  ///
  static const pharmacyName = 'pharmacy_name';

  /// `paper` or `e_prescription`.
  ///
  static const prescriptionType = 'prescription_type';

  /// How the prescription got in: `photo`, `qr_code` or `cardlink`.
  ///
  static const method = 'method';

  /// The product feature, today only `cardlink`.
  ///
  static const feature = 'feature';

  /// On `prescription_removed`: `user` or `expired`. On `feature_unavailable`: `requires_newer_os`,
  /// `nfc_not_available`, `not_registered` or `pharmacy_disabled`.
  ///
  static const reason = 'reason';
}

/// Screen names reported as [IaSdkAnalyticsParameterNames.screenName], stable across SDK versions and identical on
/// iOS and Android.
///
/// Screens not listed here are still reported, with a best-effort name that may change between releases.
///
abstract final class IaSdkAnalyticsScreenNames {
  /// The SDK's start screen.
  ///
  static const start = 'start';

  /// Product search.
  ///
  static const search = 'search';

  /// Product details.
  ///
  static const productDetails = 'product_details';

  /// The cart.
  ///
  static const cart = 'cart';

  /// Checkout.
  ///
  static const checkout = 'checkout';

  /// The screen shown after an order was placed.
  ///
  static const thankYou = 'thank_you';

  /// Pharmacy details.
  ///
  static const pharmacy = 'pharmacy';

  /// Pharmacy search (Apofinder).
  ///
  static const pharmacySearch = 'pharmacy_search';

  /// The screen for redeeming prescriptions.
  ///
  static const redeemPrescription = 'redeem_prescription';
}
