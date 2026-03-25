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
  Future<void> transferPrescriptions({
    Iterable<Uint8List>? images,
    Iterable<({Uint8List data, IaPrescriptionInsuranceType insuranceType})>? pdfs,
    Iterable<String>? codes,
    String? orderId,
  });

  /// Resets the state of user cart, clearing any added products or prescriptions.
  ///
  Future<void> clearCart();

  /// Launches the cart screen experience on top of the navigation stack.
  ///
  Future<void> launchCartScreen();

  /// Returns the current cart details, or `null` if the cart is empty.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<Map<String, dynamic>?> getCartDetails();

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
