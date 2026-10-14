part of '_models.dart';

/// CardLink SDK environment configuration.
///
enum IaCardLinkEnvironment {
  /// Non-production environment.
  ///
  /// On iOS, launching CardLink with it switches the whole SDK to its staging environment, and
  /// `getEnvironment` reports both the development and the staging environment as [debug].
  ///
  debug,

  /// Production environment.
  ///
  production;

  /// Returns the raw string value for native communication.
  ///
  String get rawValue {
    switch (this) {
      case IaCardLinkEnvironment.debug:
        return 'DEBUG';
      case IaCardLinkEnvironment.production:
        return 'PRODUCTION';
    }
  }

  /// Creates an instance from a raw string value.
  ///
  static IaCardLinkEnvironment fromRawValue(String? rawValue) {
    switch (rawValue) {
      case 'DEBUG':
        return IaCardLinkEnvironment.debug;
      case 'PRODUCTION':
      default:
        return IaCardLinkEnvironment.production;
    }
  }
}
