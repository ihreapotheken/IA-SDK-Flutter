part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK Ordering service.
///
/// Methods documented as "Only supported on iOS" or "Only supported on Android" throw a
/// [MissingPluginException] on the other platform. Callbacks and streams with such a note never fire there.
///
/// {@category Interaction}
/// {@category CartScreen}
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
  /// Call it after `IaSdk.initialize`; before that the call fails. On iOS the SDK first runs its prerequisites when
  /// needed, which can show Apofinder or the legal documents.
  ///
  /// It completes once the prescriptions are in the cart. On Android, the SDK reports that through the updated cart
  /// with [IaTransferPrescriptionsFinishAction.openCart] and [IaTransferPrescriptionsFinishAction.noAction], and
  /// only once the user has closed the confirmation with [IaTransferPrescriptionsFinishAction.showBottomSheet].
  /// Closing the transfer screen during the upload cancels it there, and the call fails.
  ///
  /// An eRezept code the SDK can't read fails the call on iOS. Android skips it and transfers the others.
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
  /// On Android, call it after `IaSdk.initialize`; before that the call fails. There it completes once clearing has
  /// started, and a failure while clearing isn't reported.
  ///
  Future<void> clearCart();

  /// Launches the cart screen experience on top of the navigation stack.
  ///
  Future<void> launchCartScreen();

  /// Returns the current cart details, or `null` if there's no cart. A cart the user emptied can be returned
  /// without items.
  ///
  /// It fails until the SDK has run its prerequisites in the current app session, for example when an SDK screen or
  /// component was shown, and again after they're reset.
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

  /// Returns the current cart as the model [orderingDidUpdateCartListener] reports, or `null` if there's no cart.
  ///
  /// Like [getCartDetails], it fails until the SDK has run its prerequisites in the current app session.
  ///
  /// The options work like those of [getCartDetails]. Client order IDs aren't part of the cart details,
  /// so [IaModelOrderingCartState.clientOrderIDs] is empty.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<IaModelOrderingCartState?> getCartState({
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
  /// On Android, where updates only carry the counts, an update with the same counts as the previous one isn't sent.
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
