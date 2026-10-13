part of '_models.dart';

/// Determines what happens with prescriptions after CardLink NFC scanning.
///
/// Only used on iOS. On Android, a CardLink flow launched by the host app always sends the raw prescriptions, as
/// with [sendRawPrescriptions].
///
enum IaCardLinkFinishAction {
  /// Send raw prescription data back to the host app.
  ///
  sendRawPrescriptions,

  /// Upload prescriptions to the server (default ordering flow).
  ///
  /// Needs the Ordering module, an API key entitled to ordering, and an initialized SDK whose prerequisites ran in
  /// the current app session, for example after an SDK screen was shown. Without them, the SDK sends the raw prescriptions instead, as with
  /// [sendRawPrescriptions].
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
