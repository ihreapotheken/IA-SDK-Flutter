/// Product in an order.
///
class IaOrderProduct {
  /// Pharmacy product number identifier.
  final String pzn;

  /// Quantity of the product.
  final int amount;

  const IaOrderProduct({
    required this.pzn,
    required this.amount,
  });

  factory IaOrderProduct.fromJson(Map<String, dynamic> json) {
    return IaOrderProduct(
      pzn: json['pzn'] as String,
      amount: json['amount'] as int,
    );
  }
}
