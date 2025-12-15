part of 'sdk.dart';

/// Basic definition for the ia.de SDK client configuration.
///
class IaSdkConfiguration {
  /// Generates an instance of the ia.de SDK client configuration.
  ///
  /// For more information, see [accessKey], [clientId], and [serverEnvironment].
  ///
  IaSdkConfiguration({
    required this.accessKey,
    required this.clientId,
    required this.serverEnvironment,
  });

  /// Key used to authenticate the client setup with the backend service.
  ///
  /// Provided to clients by the ia.de team on an individual basis.
  ///
  final String accessKey;

  /// Client identifier used to determine the pharmacy channel specification.
  ///
  /// Provided to clients by the ia.de team on an individual basis.
  ///
  final String clientId;

  /// Selected server environment specification.
  ///
  /// Currently only available with the iOS platform.
  ///
  /// See [IaSdkConfigServerEnvironment] for further information.
  ///
  final IaSdkConfigServerEnvironment serverEnvironment;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, String> toJson() {
    return {
      'accessKey': accessKey,
      'clientId': clientId,
      'serverEnvironment': serverEnvironment.name,
    };
  }
}

/// Identifier for the ia.de server environments.
///
/// 3 different server environments are set up: DEV, QA, and PROD.
///
/// The `development` and `staging` environments are set up for internal testing
/// and are accessible with VPN only, while the `production` environment is the
/// production-ready environment to which the end-users have access.
///
/// VPN access can be provided by the ia.de team on inquiry.
///
enum IaSdkConfigServerEnvironment {
  /// https://ihreapotheken.de/
  ///
  /// Production / live server environment.
  ///
  production,

  /// https://qa.ihreapotheken.de/
  ///
  /// QA server environment, requires VPN for access.
  ///
  staging,

  /// https://dev.ihreapotheken.de/
  ///
  /// DEV server environment, requires VPN for access.
  ///
  development,
}

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

  String get _nativeValue {
    return switch (this) {
      IaRouteOverride.cart => 'cart',
      IaRouteOverride.pharmacyDetails => 'pharmacyDetails',
      IaRouteOverride.thankYou => 'thankYou',
      IaRouteOverride.imprint => 'imprint',
      IaRouteOverride.hostAppPrivacyPolicy => 'hostAppPrivacyPolicy',
      IaRouteOverride.apofinder => 'apofinder',
    };
  }

  static IaRouteOverride? _fromNativeValue(String value) {
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

/// Decision for how the SDK should handle a particular action.
///
enum IaHandlingDecision {
  /// The host app has handled the action, SDK should not perform its default behavior.
  handled,

  /// The SDK should perform its default behavior.
  performDefault;

  String get _nativeValue {
    return switch (this) {
      IaHandlingDecision.handled => 'handled',
      IaHandlingDecision.performDefault => 'performDefault',
    };
  }

  static IaHandlingDecision? _fromNativeValue(String value) {
    return switch (value) {
      'handled' => IaHandlingDecision.handled,
      'performDefault' => IaHandlingDecision.performDefault,
      _ => null,
    };
  }
}
