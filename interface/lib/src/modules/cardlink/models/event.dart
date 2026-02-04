part of '_models.dart';

/// CardLink lifecycle and interaction events.
///
/// These events represent various states and actions during the CardLink flow.
///
enum IaCardLinkEvent {
  /// CardLink will exit/close.
  ///
  willExit,

  /// NFC scanning is about to start.
  ///
  willStartScanning,

  /// CardLink failed to initialize.
  ///
  failedToInitialize,

  /// User requested to go to cart.
  ///
  goToCart,

  /// User requested to open terms and conditions.
  ///
  openTermsAndConditions,

  /// A card (CAN code) was saved.
  ///
  cardSaved;

  /// Returns the raw string value for native communication.
  ///
  String get rawValue {
    switch (this) {
      case IaCardLinkEvent.willExit:
        return 'willExitCardlink';
      case IaCardLinkEvent.willStartScanning:
        return 'willStartScanning';
      case IaCardLinkEvent.failedToInitialize:
        return 'cardlinkFailedToInitialize';
      case IaCardLinkEvent.goToCart:
        return 'goToCart';
      case IaCardLinkEvent.openTermsAndConditions:
        return 'openTermsAndConditions';
      case IaCardLinkEvent.cardSaved:
        return 'saveCard';
    }
  }

  /// Creates an instance from a raw string value.
  ///
  static IaCardLinkEvent fromRawValue(String rawValue) {
    switch (rawValue) {
      case 'willExitCardlink':
        return IaCardLinkEvent.willExit;
      case 'willStartScanning':
        return IaCardLinkEvent.willStartScanning;
      case 'cardlinkFailedToInitialize':
        return IaCardLinkEvent.failedToInitialize;
      case 'goToCart':
        return IaCardLinkEvent.goToCart;
      case 'openTermsAndConditions':
        return IaCardLinkEvent.openTermsAndConditions;
      case 'saveCard':
        return IaCardLinkEvent.cardSaved;
      default:
        throw ArgumentError('Unknown CardLink event: $rawValue');
    }
  }
}
