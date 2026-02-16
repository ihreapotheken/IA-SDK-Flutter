part of '_models.dart';

/// Determines what happens with prescriptions after CardLink NFC scanning.
///
enum IaCardLinkFinishAction {
  /// Send raw prescription data back to the host app.
  ///
  sendRawPrescriptions,

  /// Upload prescriptions to the server (default ordering flow).
  ///
  uploadPrescriptions;

  /// Returns the raw string value for native communication.
  ///
  String get rawValue {
    switch (this) {
      case IaCardLinkFinishAction.sendRawPrescriptions:
        return 'sendRawPrescriptions';
      case IaCardLinkFinishAction.uploadPrescriptions:
        return 'uploadPrescriptions';
    }
  }

  /// Creates an instance from a raw string value.
  ///
  static IaCardLinkFinishAction fromRawValue(String rawValue) {
    switch (rawValue) {
      case 'sendRawPrescriptions':
        return IaCardLinkFinishAction.sendRawPrescriptions;
      case 'uploadPrescriptions':
        return IaCardLinkFinishAction.uploadPrescriptions;
      default:
        throw ArgumentError('Unknown finish action: $rawValue');
    }
  }
}
