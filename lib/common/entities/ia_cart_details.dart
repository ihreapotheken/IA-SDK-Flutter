import 'package:appsdk_v2_flutter_plugin/common/entities/ia_order_product.dart';

/// Cart details containing products and amounts.
///
class IaCartDetails {
  /// Array of products in the cart.
  final List<IaOrderProduct> products;

  /// Total number of items in cart (products + prescriptions, each unit counted individually).
  final int totalAmountInCart;

  const IaCartDetails({
    required this.products,
    required this.totalAmountInCart,
  });

  factory IaCartDetails.fromJson(Map<String, dynamic> json) {
    final productsList = json['products'] as List<dynamic>;
    final products = productsList
        .map((p) => IaOrderProduct.fromJson(Map<String, dynamic>.from(p as Map)))
        .toList();

    return IaCartDetails(
      products: products,
      totalAmountInCart: json['totalAmountInCart'] as int,
    );
  }
}
