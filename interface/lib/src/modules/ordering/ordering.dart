part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK Ordering service.
///
abstract class IaBaseOrdering extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.ordering;
  }

  /// Forwards the specified [images], [pdfs], or eRezept [codes] prescription collection to the ia.de backend.
  ///
  /// Each PDF entry is a record containing the binary data and its [IaPrescriptionInsuranceType].
  ///
  /// [finishAction] decides what the SDK shows once the transfer is done. [showActivityIndicator] decides whether
  /// a loading indicator is shown during the transfer, and is only used on iOS.
  ///
  Future<void> transferPrescriptions({
    Iterable<Uint8List>? images,
    Iterable<({Uint8List data, IaPrescriptionInsuranceType insuranceType})>? pdfs,
    Iterable<String>? codes,
    String? orderId,
    IaTransferPrescriptionsFinishAction finishAction = IaTransferPrescriptionsFinishAction.openCart,
    bool showActivityIndicator = true,
  });

  /// Resets the state of user cart, clearing any added products or prescriptions.
  ///
  Future<void> clearCart();

  /// Launches the cart screen experience on top of the navigation stack.
  ///
  Future<void> launchCartScreen();

  /// Returns the current cart details, or `null` if the cart is empty.
  ///
  /// With [allowCached] the SDK may return previously loaded details instead of loading them again.
  /// With [shouldEmitCartUpdate] the result is also reported through [orderingDidUpdateCartListener].
  ///
  /// Note: Only supported on iOS.
  ///
  Future<Map<String, dynamic>?> getCartDetails({
    bool allowCached = true,
    bool shouldEmitCartUpdate = false,
  });

  /// Deletes the order history.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> deleteOrderHistory();

  /// Notifier object implemented for informing the client integration of order completion.
  ///
  /// Usage:
  ///
  /// ```dart
  /// orderingDidFinishOrderListener.stream.listen((data) {
  ///   // Process data.
  /// });
  /// ```
  ///
  StreamController<IaModelOrderingTransactionSignatures> get orderingDidFinishOrderListener;

  /// Notifier object implemented for informing the client integration of cart item changes.
  ///
  /// Usage:
  ///
  /// ```dart
  /// orderingDidUpdateCartListener.stream.listen((data) {
  ///   // Process data.
  /// });
  /// ```
  ///
  StreamController<IaModelOrderingCartState> get orderingDidUpdateCartListener;
}
