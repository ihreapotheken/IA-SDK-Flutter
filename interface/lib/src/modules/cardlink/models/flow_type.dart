part of '_models.dart';

/// CardLink flow type determining which experience to launch.
///
enum IaCardLinkFlowType {
  /// Launch the main CardLink NFC scanning flow.
  ///
  cardLink,

  /// Launch the saved cards management view.
  ///
  savedCards;

  /// Returns the raw string value for native communication.
  ///
  String get rawValue {
    switch (this) {
      case IaCardLinkFlowType.cardLink:
        return 'launchCardLinkSdk';
      case IaCardLinkFlowType.savedCards:
        return 'launchCardLinkCards';
    }
  }

  /// Creates an instance from a raw string value.
  ///
  static IaCardLinkFlowType fromRawValue(String rawValue) {
    switch (rawValue) {
      case 'launchCardLinkSdk':
        return IaCardLinkFlowType.cardLink;
      case 'launchCardLinkCards':
        return IaCardLinkFlowType.savedCards;
      default:
        throw ArgumentError('Unknown flow type: $rawValue');
    }
  }
}
