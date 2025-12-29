/// State of the shopping cart.
///
class IaCart {
  /// Total number of items in cart (products + prescriptions, each unit counted individually).
  final int totalAmountInCart;

  /// Array of external/client order IDs.
  final List<String> clientOrderIDs;

  const IaCart({
    required this.totalAmountInCart,
    required this.clientOrderIDs,
  });
}
