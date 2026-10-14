part of '_models.dart';

/// CardLink lifecycle and interaction events.
///
/// These events represent various states and actions during the CardLink flow.
///
enum IaCardLinkEvent {
  /// CardLink has closed.
  ///
  /// It's reported once CardLink is gone, on Android when its last screen has closed. When the user continues from
  /// the saved cards screen into the scan flow on Android, the SDK can close the saved cards screen before the scan
  /// flow opens. It's then reported for both.
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
  /// Note: Only reported on Android. The iOS 2.9.0 SDK never sends this action.
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
  /// The saved cards flow only reports it when the backend has card saving turned off, as the SDK then opens the
  /// CardLink flow instead. Its saved cards screen returns no result.
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
