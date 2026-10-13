part of '_models.dart';

/// CardLink lifecycle and interaction events.
///
/// These events represent various states and actions during the CardLink flow.
///
enum IaCardLinkEvent {
  /// CardLink will exit/close.
  ///
  /// On Android it's reported once CardLink has closed, when the host app's screen shows again.
  ///
  willExit,

  /// NFC scanning is about to start.
  ///
  /// Note: Only reported on iOS.
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

  /// A card (CAN code) was saved. The saved cards are reported through `savedCardsListener`.
  ///
  cardSaved,

  /// CardLink closed with a result, reported through `resultListener`.
  ///
  /// Not reported for the saved cards flow, whose Android screen returns no result.
  ///
  /// Note: Only reported on Android.
  ///
  finished;

  /// Returns the raw string value for native communication.
  ///
  String get rawValue {
    switch (this) {
      case IaCardLinkEvent.willExit:
        return 'willExitCardlink';
      case IaCardLinkEvent.willStartScanning:
        return 'willStartScanning';
      case IaCardLinkEvent.failedToInitialize:
        return 'failedToInitialize';
      case IaCardLinkEvent.goToCart:
        return 'goToCart';
      case IaCardLinkEvent.openTermsAndConditions:
        return 'openTermsAndConditions';
      case IaCardLinkEvent.cardSaved:
        return 'cardSaved';
      case IaCardLinkEvent.finished:
        return 'cardLinkResult';
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
      case 'failedToInitialize':
        return IaCardLinkEvent.failedToInitialize;
      case 'goToCart':
        return IaCardLinkEvent.goToCart;
      case 'openTermsAndConditions':
        return IaCardLinkEvent.openTermsAndConditions;
      case 'cardSaved':
        return IaCardLinkEvent.cardSaved;
      case 'cardLinkResult':
        return IaCardLinkEvent.finished;
      default:
        throw ArgumentError('Unknown CardLink event: $rawValue');
    }
  }
}
