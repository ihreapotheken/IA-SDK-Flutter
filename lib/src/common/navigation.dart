part of '../core.dart';

class _NavigationHandler implements IaBaseCallbackHandler {
  const _NavigationHandler();

  @override
  String get methodId {
    return 'sdkWillNavigateToTarget';
  }

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      if (args is! String) {
        throw Exception(
          'Arguments not of type String for _NavigationHandler.',
        );
      }
      if (IaSdk.instance.onSdkWillNavigateToTarget != null) {
        final target = IaSdkNavigationTarget.fromRawValue(args);
        final result = await IaSdk.instance.onSdkWillNavigateToTarget!(target);
        if (result) {
          return _NavigationHandlingDecision.performDefault.name;
        } else {
          return _NavigationHandlingDecision.handled.name;
        }
      } else {
        return _NavigationHandlingDecision.performDefault.name;
      }
    };
  }
}

/// Navigation targets that the SDK may navigate to, which the host app can optionally override.
///
enum IaSdkNavigationTarget {
  /// SDK intends to open cart screen. This can be called from multiple points in the SDK.
  ///
  cart,

  /// SDK intends to open pharmacy details screen. This can be called from multiple points in the SDK.
  ///
  pharmacyDetails,

  /// Called after order and payment is processed and just before it will show thank you screen.
  /// Default behavior is to present SDK's thank you screen.
  ///
  thankYou,

  /// "Impressum" button is tapped on the footer. If not handled it will open webview with content from CMS.
  ///
  imprint,

  /// "Datenverarbeitung" button is tapped on the footer. Nothing happens if not handled.
  ///
  hostAppPrivacyPolicy,

  /// SDK intends to open Apofinder from an internal flow (not prerequisites).
  /// Triggers include product details ("Apotheke wählen") and pharmacy screen (change pharmacy).
  ///
  apofinder
  ;

  factory IaSdkNavigationTarget.fromRawValue(String value) {
    return switch (value) {
      'cart' => IaSdkNavigationTarget.cart,
      'pharmacyDetails' => IaSdkNavigationTarget.pharmacyDetails,
      'thankYou' => IaSdkNavigationTarget.thankYou,
      'imprint' => IaSdkNavigationTarget.imprint,
      'hostAppPrivacyPolicy' => IaSdkNavigationTarget.hostAppPrivacyPolicy,
      'apofinder' => IaSdkNavigationTarget.apofinder,
      _ => throw Exception(
        'No navigation target $value found.',
      ),
    };
  }
}

/// Decision for how the SDK should handle a particular action.
///
enum _NavigationHandlingDecision {
  /// The host app has handled the action, SDK should not perform its default behavior.
  ///
  handled,

  /// The SDK should perform its default behavior.
  ///
  performDefault,
}
