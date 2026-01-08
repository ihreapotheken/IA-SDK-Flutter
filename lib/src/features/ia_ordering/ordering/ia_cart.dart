/// State of the shopping cart.
///
class IaModelCart {
  /// Total number of items in cart (products + prescriptions, each unit counted individually).
  final int totalAmountInCart;

  /// Array of external/client order IDs.
  final List<String> clientOrderIDs;

  const IaModelCart({
    required this.totalAmountInCart,
    required this.clientOrderIDs,
  });
}
