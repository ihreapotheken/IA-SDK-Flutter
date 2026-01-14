part of '_models.dart';

/// State of the shopping cart.
///
class IaModelOrderingCartState {
  /// Constructs a new instance of the [IaModelOrderingCartState] object.
  ///
  const IaModelOrderingCartState({
    required this.totalAmountInCart,
    required this.clientOrderIDs,
  });

  /// Total number of items in cart (products + prescriptions, each unit counted individually).
  final int totalAmountInCart;

  /// Array of external/client order IDs.
  final List<String> clientOrderIDs;
}
