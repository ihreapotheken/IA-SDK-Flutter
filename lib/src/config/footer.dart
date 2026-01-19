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

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'shouldShowDataProcessing': shouldShowDataProcessing,
      'shouldShowAppSettings': shouldShowAppSettings,
      'shouldShowImprint': shouldShowImprint,
    };
  }
}
