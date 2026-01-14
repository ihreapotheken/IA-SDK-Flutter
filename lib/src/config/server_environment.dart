part of '../core.dart';

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
enum IaSdkConfigurationServerEnvironment {
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
