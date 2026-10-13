part of '../core.dart';

/// QA options for testing an integration. Not meant for production builds.
///
class IaSdkConfigurationQa {
  /// Generates an instance of QA configuration.
  ///
  const IaSdkConfigurationQa({
    this.showTestPharmaciesInApofinder = false,
    this.features = const {},
    this.apofinderCustomPharmacyId,
    this.maxScrollSpeed,
    this.mockSdkFeatures,
    this.mockBundlePermissions,
    this.mockForceUpdate,
  }) : assert(
         maxScrollSpeed == null || (maxScrollSpeed > -double.infinity && maxScrollSpeed < double.infinity),
         'maxScrollSpeed must be a finite number.',
       );

  /// Whether Apofinder also lists test pharmacies.
  ///
  final bool showTestPharmaciesInApofinder;

  /// Additional QA tools to turn on.
  ///
  /// Note: Only used on iOS.
  ///
  final Set<IaSdkQaFeature> features;

  /// Numeric pharmacy identifier, for example `"1234"`, that Apofinder offers in addition to the found pharmacies.
  /// Other values make [IaSdk.initialize] fail.
  ///
  /// Note: Only used on Android.
  ///
  final String? apofinderCustomPharmacyId;

  /// Upper limit for the scroll speed in SDK lists. Must be a finite number; leave it `null` for no limit.
  ///
  /// Note: Only used on Android.
  ///
  final double? maxScrollSpeed;

  /// Replaces the SDK features enabled for the pharmacy. `null` uses the real configuration.
  ///
  /// Note: Only used on Android.
  ///
  final IaSdkQaMockSdkFeatures? mockSdkFeatures;

  /// Replaces the modules the API key is entitled to. `null` uses the real entitlements.
  ///
  /// Note: Only used on Android.
  ///
  final IaSdkQaMockBundlePermissions? mockBundlePermissions;

  /// Simulates a required app update. `null` uses the real update check.
  ///
  /// Note: Only used on Android.
  ///
  final IaSdkQaMockForceUpdate? mockForceUpdate;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'showTestPharmaciesInApofinder': showTestPharmaciesInApofinder,
      'features': features.map((feature) => feature.name).toList(),
      'apofinderCustomPharmacyId': apofinderCustomPharmacyId,
      'maxScrollSpeed': maxScrollSpeed,
      'mockSdkFeatures': mockSdkFeatures?.toJson(),
      'mockBundlePermissions': mockBundlePermissions?.toJson(),
      'mockForceUpdate': mockForceUpdate?.toJson(),
    };
  }
}

/// QA tools of the iOS SDK.
///
enum IaSdkQaFeature {
  /// Allows opening the SDK logs in production builds.
  ///
  easyLogsAccessInProduction,

  /// Shows a button to force-refresh the cart screen.
  ///
  forceRefreshCartScreenButton,

  /// Shows a button with the pharmacy's PCases.
  ///
  pharmacyPCasesInfoButton,

  /// Shows product details on a long press.
  ///
  longPressProductInfo,

  /// Shows SDK information in the navigation bar.
  ///
  sdkInfoInNavigationBar,

  /// Warns when interacting with a real pharmacy.
  ///
  showInteractionWithRealPharmacyWarning,

  /// Lets the user enter a pharmacy identifier in Apofinder.
  ///
  showPharmacyIdInputOnApofinder,

  /// Shows debug details in the image viewer.
  ///
  imageViewerDebugDetails,

  /// Includes the scanned code in scanner error messages.
  ///
  showFailedScannedCodeInErrorMessage,

  /// Logs first responder changes.
  ///
  enableFirstResponderLogging,

  /// Shows lab test activation code details.
  ///
  showLabTestActivationCodeDetails,
}

/// Mocked SDK features of the pharmacy, see [IaSdkConfigurationQa.mockSdkFeatures].
///
class IaSdkQaMockSdkFeatures {
  /// Generates an instance of mocked SDK features.
  ///
  const IaSdkQaMockSdkFeatures({
    this.isExpressDeliveryEnabled = true,
    this.isOnlinePaymentEnabled = true,
    this.isTrackingEnabled = false,
    this.isCardLinkEnabled = true,
  });

  /// Whether express delivery is offered.
  ///
  final bool isExpressDeliveryEnabled;

  /// Whether online payment is offered.
  ///
  final bool isOnlinePaymentEnabled;

  /// Whether tracking is enabled.
  ///
  final bool isTrackingEnabled;

  /// Whether CardLink is offered.
  ///
  final bool isCardLinkEnabled;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'isExpressDeliveryEnabled': isExpressDeliveryEnabled,
      'isOnlinePaymentEnabled': isOnlinePaymentEnabled,
      'isTrackingEnabled': isTrackingEnabled,
      'isCardLinkEnabled': isCardLinkEnabled,
    };
  }
}

/// Mocked module entitlements, see [IaSdkConfigurationQa.mockBundlePermissions].
///
class IaSdkQaMockBundlePermissions {
  /// Generates an instance of mocked module entitlements.
  ///
  const IaSdkQaMockBundlePermissions({
    this.isOverTheCounterEnabled = true,
    this.isOrderingEnabled = true,
    this.isPharmacyEnabled = true,
    this.isPrescriptionEnabled = true,
    this.isCardLinkEnabled = true,
  });

  /// Whether the over-the-counter module is entitled.
  ///
  final bool isOverTheCounterEnabled;

  /// Whether the ordering module is entitled.
  ///
  final bool isOrderingEnabled;

  /// Whether the pharmacy module is entitled.
  ///
  final bool isPharmacyEnabled;

  /// Whether the prescription module is entitled.
  ///
  final bool isPrescriptionEnabled;

  /// Whether the CardLink module is entitled.
  ///
  final bool isCardLinkEnabled;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'isOverTheCounterEnabled': isOverTheCounterEnabled,
      'isOrderingEnabled': isOrderingEnabled,
      'isPharmacyEnabled': isPharmacyEnabled,
      'isPrescriptionEnabled': isPrescriptionEnabled,
      'isCardLinkEnabled': isCardLinkEnabled,
    };
  }
}

/// Mocked required app update, see [IaSdkConfigurationQa.mockForceUpdate].
///
class IaSdkQaMockForceUpdate {
  /// Generates an instance of a mocked app update.
  ///
  const IaSdkQaMockForceUpdate({
    this.isHardUpdate = false,
    this.minimumVersion = '999.0.0',
    this.message = 'Please update the app to continue.',
    this.playStoreId,
  });

  /// Whether the update blocks the SDK (hard update) or can be skipped (soft update).
  ///
  final bool isHardUpdate;

  /// Minimum app version the simulated update requires.
  ///
  final String minimumVersion;

  /// Message shown to the user.
  ///
  final String message;

  /// Google Play identifier linked from the update prompt.
  ///
  final String? playStoreId;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'isHardUpdate': isHardUpdate,
      'minimumVersion': minimumVersion,
      'message': message,
      'playStoreId': playStoreId,
    };
  }
}
