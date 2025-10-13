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
