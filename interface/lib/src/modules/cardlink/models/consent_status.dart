part of '_models.dart';

/// Initial consent status to pass when launching CardLink.
///
/// This determines whether the user should be shown the consent screen
/// or if their previous consent decision should be used.
///
enum IaCardLinkConsentStatus {
  /// Show the consent screen to the user.
  ///
  showConsent,

  /// User has previously accepted consent.
  ///
  consentAccepted,

  /// User has previously declined consent.
  ///
  consentDeclined;

  /// Returns the raw string value for native communication.
  ///
  String get rawValue {
    switch (this) {
      case IaCardLinkConsentStatus.showConsent:
        return 'SHOW_CONSENT';
      case IaCardLinkConsentStatus.consentAccepted:
        return 'CONSENT_ACCEPTED';
      case IaCardLinkConsentStatus.consentDeclined:
        return 'CONSENT_DECLINED';
    }
  }

  /// Creates an instance from a raw string value.
  ///
  static IaCardLinkConsentStatus fromRawValue(String rawValue) {
    switch (rawValue) {
      case 'SHOW_CONSENT':
        return IaCardLinkConsentStatus.showConsent;
      case 'CONSENT_ACCEPTED':
        return IaCardLinkConsentStatus.consentAccepted;
      case 'CONSENT_DECLINED':
        return IaCardLinkConsentStatus.consentDeclined;
      default:
        throw ArgumentError('Unknown consent status: $rawValue');
    }
  }
}
