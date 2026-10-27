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
      final rawTarget = args is Map ? args['navigationTarget'] : args;
      if (rawTarget is! String) {
        throw Exception(
          'Missing or invalid navigationTarget for _NavigationHandler: $args.',
        );
      }
      final target = IaSdkNavigationTarget.values.where((value) => value.name == rawTarget).firstOrNull;
      if (target != null && IaSdk.instance.onSdkWillNavigateToTarget != null) {
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
/// {@category Interaction}
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
  /// Note: On Android only reported with [IaSdkConfigurationFooter.isImprintHandledByHostApp], and the SDK
  /// then never opens its own imprint page.
  ///
  imprint,

  /// SDK intends to open Apofinder from an internal flow (not prerequisites).
  /// Triggers include product details ("Apotheke wählen") and pharmacy screen (change pharmacy).
  ///
  apofinder,

  /// SDK intends to open the start screen.
  ///
  /// Note: Only reported on Android.
  ///
  start,

  /// SDK intends to open the product search.
  ///
  /// Note: Only reported on Android.
  ///
  search,

  /// SDK intends to open the "redeem prescription" screen.
  ///
  /// Note: Only reported on Android.
  ///
  redeemPrescription,

  /// The SDK finished the thank-you screen shown after an order.
  ///
  /// Note: Only reported on Android.
  ///
  thankYouCompleted,
  ;

  factory IaSdkNavigationTarget.fromRawValue(String value) {
    return switch (value) {
      'cart' => IaSdkNavigationTarget.cart,
      'pharmacyDetails' => IaSdkNavigationTarget.pharmacyDetails,
      'thankYou' => IaSdkNavigationTarget.thankYou,
      'imprint' => IaSdkNavigationTarget.imprint,
      'apofinder' => IaSdkNavigationTarget.apofinder,
      'start' => IaSdkNavigationTarget.start,
      'search' => IaSdkNavigationTarget.search,
      'redeemPrescription' => IaSdkNavigationTarget.redeemPrescription,
      'thankYouCompleted' => IaSdkNavigationTarget.thankYouCompleted,
      _ => throw Exception(
        'No navigation target $value found.',
      ),
    };
  }
}

class _ApofinderPharmacyChangedHandler implements IaBaseCallbackHandler {
  const _ApofinderPharmacyChangedHandler();

  @override
  String get methodId => 'apofinderDidChangePharmacy';

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return (args) async {
      if (args is! Map) return null;
      final pharmacyId = args['pharmacyId'] as String?;
      final isFromPrerequisites = args['isFromPrerequisites'] as bool? ?? false;
      if (pharmacyId != null && IaSdk.instance.onApofinderDidChangePharmacy != null) {
        IaSdk.instance.onApofinderDidChangePharmacy!(
          pharmacyId: pharmacyId,
          isFromPrerequisites: isFromPrerequisites,
        );
      }
      return null;
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
