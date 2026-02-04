part of '_models.dart';

/// CardLink SDK environment configuration.
///
enum IaCardLinkEnvironment {
  /// Debug/development environment.
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
