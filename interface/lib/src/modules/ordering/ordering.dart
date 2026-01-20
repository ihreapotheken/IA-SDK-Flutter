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
  Future<void> transferPrescriptions({
    Iterable<Uint8List>? images,
    Iterable<Uint8List>? pdfs,
    Iterable<String>? codes,
    String? orderId,
  });

  /// Resets the state of user cart, clearing any added products or prescriptions.
  ///
  Future<void> clearCart();

  /// Launches the cart screen experience on top of the navigation stack.
  ///
  Future<void> launchCartScreen();

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
