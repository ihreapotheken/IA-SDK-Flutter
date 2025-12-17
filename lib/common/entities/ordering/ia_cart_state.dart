import 'package:appsdk_v2_flutter_plugin/common/entities/ordering/ia_cart_details.dart';

/// State of the shopping cart.
///
class IaCartState {
  /// Optional cart details containing products and amounts.
  final IaCartDetails? cartDetails;

  /// Array of external/client order IDs.
  final List<String> clientOrderIDs;

  const IaCartState({
    this.cartDetails,
    required this.clientOrderIDs,
  });

  factory IaCartState.fromJson(Map<String, dynamic> json) {
    final cartDetailsRaw = json['cartDetails'];
    final cartDetailsJson = cartDetailsRaw != null ? Map<String, dynamic>.from(cartDetailsRaw as Map) : null;
    final clientOrderIDsList = json['clientOrderIDs'] as List<dynamic>;

    return IaCartState(
      cartDetails: cartDetailsJson != null ? IaCartDetails.fromJson(cartDetailsJson) : null,
      clientOrderIDs: clientOrderIDsList.map((id) => id as String).toList(),
    );
  }
}
