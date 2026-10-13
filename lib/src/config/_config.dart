part of '../core.dart';

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
    this.shouldFetchThemeFromRemote = true,
    this.footer = const IaSdkConfigurationFooter(),
    this.initialization = const IaSdkConfigurationInitialization(),
    this.uiConfiguration = const IaUIConfiguration(),
    this.isPickupLockerAndCourierShippingEnabled,
    this.appStoreId,
    this.playStoreId,
    this.isAnalyticsEnabled,
    this.isHapticFeedbackEnabled,
    this.qaConfiguration,
    this.cardLink,
    this.hostAppLogFilePath,
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
  /// See [IaSdkConfigurationServerEnvironment] for further information.
  ///
  final IaSdkConfigurationServerEnvironment serverEnvironment;

  /// Whether to fetch theme configuration from remote server.
  ///
  final bool shouldFetchThemeFromRemote;

  /// Footer configuration options.
  ///
  final IaSdkConfigurationFooter footer;

  /// Initialization configuration options.
  ///
  final IaSdkConfigurationInitialization initialization;

  /// UI appearance configuration options.
  ///
  final IaUIConfiguration uiConfiguration;

  /// Whether checkout offers pickup locker and courier shipping as delivery options.
  ///
  /// `null` keeps the SDK default.
  ///
  final bool? isPickupLockerAndCourierShippingEnabled;

  /// App Store identifier of the host app, used by the SDK to link to the store listing (for example for updates).
  ///
  /// Note: Only used on iOS. See [playStoreId] for Android.
  ///
  final String? appStoreId;

  /// Google Play identifier of the host app, used by the SDK to link to the store listing (for example for updates).
  ///
  /// Note: Only used on Android. See [appStoreId] for iOS.
  ///
  final String? playStoreId;

  /// Whether the SDK tracks analytics events, reported through [IaSdk.analyticsEventListener].
  ///
  /// `null` keeps the SDK default.
  ///
  /// Note: Only used on Android.
  ///
  final bool? isAnalyticsEnabled;

  /// Whether SDK screens use haptic feedback. Can be changed later with [IaSdk.setHapticFeedbackEnabled].
  ///
  /// `null` keeps the SDK default.
  ///
  /// Note: Only used on Android.
  ///
  final bool? isHapticFeedbackEnabled;

  /// QA options for testing an integration. Not meant for production builds.
  ///
  /// `null` keeps the SDK defaults, which enable no QA option.
  ///
  final IaSdkConfigurationQa? qaConfiguration;

  /// Configuration for CardLink flows the SDK starts itself, for example from the "redeem prescription" screen.
  ///
  final IaSdkConfigurationCardLink? cardLink;

  /// Path to the host app's log file, attached to problem reports sent from SDK screens.
  ///
  /// On Android it's attached to CardLink problem reports, when the CardLink module is registered.
  ///
  final String? hostAppLogFilePath;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'accessKey': accessKey,
      'clientId': clientId,
      'serverEnvironment': serverEnvironment.name,
      'shouldFetchThemeFromRemote': shouldFetchThemeFromRemote,
      'footer': footer.toJson(),
      'initialization': initialization.toJson(),
      'uiConfiguration': uiConfiguration.toJson(),
      'isPickupLockerAndCourierShippingEnabled': isPickupLockerAndCourierShippingEnabled,
      'appStoreId': appStoreId,
      'playStoreId': playStoreId,
      'isAnalyticsEnabled': isAnalyticsEnabled,
      'isHapticFeedbackEnabled': isHapticFeedbackEnabled,
      'qaConfiguration': qaConfiguration?.toJson(),
      'cardLink': cardLink?.toJson(),
      'hostAppLogFilePath': hostAppLogFilePath,
    };
  }
}
