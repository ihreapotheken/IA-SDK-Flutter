part of '../core.dart';

/// Configuration options for SDK footer buttons.
///
class IaSdkConfigurationFooter {
  /// Generates an instance of footer configuration.
  ///
  const IaSdkConfigurationFooter({
    this.shouldShowDataProcessing = true,
    this.shouldShowAppSettings = true,
    this.shouldShowImprint = true,
    this.isImprintHandledByHostApp = false,
  });

  /// Whether to show the data processing button in the footer.
  ///
  final bool shouldShowDataProcessing;

  /// Whether to show the app settings button in the footer.
  ///
  final bool shouldShowAppSettings;

  /// Whether to show the imprint button in the footer.
  ///
  final bool shouldShowImprint;

  /// Whether the host app shows the imprint itself, when the imprint button reports [IaSdkNavigationTarget.imprint].
  ///
  /// iOS always asks [IaSdk.onSdkWillNavigateToTarget] and opens its own imprint page unless the host handles it.
  /// The Android SDK can't ask, so it either opens its own imprint page or, with this flag, only reports the tap.
  ///
  /// Note: Only used on Android.
  ///
  final bool isImprintHandledByHostApp;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'shouldShowDataProcessing': shouldShowDataProcessing,
      'shouldShowAppSettings': shouldShowAppSettings,
      'shouldShowImprint': shouldShowImprint,
      'isImprintHandledByHostApp': isImprintHandledByHostApp,
    };
  }
}
