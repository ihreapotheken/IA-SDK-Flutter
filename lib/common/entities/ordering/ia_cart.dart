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

  factory IaCart.fromJson(Map<String, dynamic> json) {
    final clientOrderIDsList = json['clientOrderIDs'] as List<dynamic>;

    return IaCart(
      totalAmountInCart: json['totalAmountInCart'] as int,
      clientOrderIDs: clientOrderIDsList.map((id) => id as String).toList(),
    );
  }
}
