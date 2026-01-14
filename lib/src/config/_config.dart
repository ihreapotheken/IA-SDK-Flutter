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
    };
  }
}
