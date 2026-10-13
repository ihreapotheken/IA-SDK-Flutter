part of '_models.dart';

/// State of the shopping cart.
///
class IaModelOrderingCartState {
  /// Constructs a new instance of the [IaModelOrderingCartState] object.
  ///
  const IaModelOrderingCartState({
    required this.totalAmountInCart,
    required this.clientOrderIDs,
    this.totalProducts,
    this.totalPrescriptions,
    this.products,
  });

  /// Total number of items in cart (products + prescriptions, each unit counted individually).
  final int totalAmountInCart;

  /// Array of external/client order IDs.
  ///
  /// Always empty on Android, which doesn't report them, and from `getCartState`, whose cart details don't include them.
  final List<String> clientOrderIDs;

  /// Number of products in the cart. Only reported on Android.
  final int? totalProducts;

  /// Number of prescriptions in the cart. Only reported on Android.
  final int? totalPrescriptions;

  /// Products in the cart with their amounts. Only reported on iOS, `null` on Android.
  final List<IaModelOrderingCartProduct>? products;
}

/// Product in the shopping cart.
///
class IaModelOrderingCartProduct {
  /// Constructs a new instance of the [IaModelOrderingCartProduct] object.
  ///
  const IaModelOrderingCartProduct({
    required this.pzn,
    required this.amount,
  });

  /// Product identifier.
  final String pzn;

  /// Number of units in the cart.
  final int amount;
}
