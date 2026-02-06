part of '_models.dart';

/// Event emitted when user responds to the CardLink consent prompt.
///
/// Consolidates consent accepted/declined events into a single stream
/// with status differentiation.
///
enum IaCardLinkConsentEvent {
  /// User accepted the CardLink consent.
  ///
  accepted,

  /// User declined the CardLink consent.
  ///
  declined;

  /// Returns the raw string value for native communication.
  ///
  String get rawValue {
    switch (this) {
      case IaCardLinkConsentEvent.accepted:
        return 'accepted';
      case IaCardLinkConsentEvent.declined:
        return 'declined';
    }
  }

  /// Creates an instance from a raw string value.
  ///
  static IaCardLinkConsentEvent fromRawValue(String rawValue) {
    switch (rawValue) {
      case 'accepted':
        return IaCardLinkConsentEvent.accepted;
      case 'declined':
        return IaCardLinkConsentEvent.declined;
      default:
        throw ArgumentError('Unknown consent event: $rawValue');
    }
  }
}
