import 'package:appsdk_v2_flutter_plugin/common/entities/ordering/ia_cart.dart';
import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/foundation.dart';

class OrderingDidUpdateCartCallbackHandler {
  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    // Check if callback is set first - no point processing if host app isn't listening
    final callback = publicApi.callbacks.onOrderingDidUpdateCart;
    if (callback == null) {
      return null;
    }

    // Extract cart info from arguments
    if (arguments is! Map) {
      debugPrint('orderingDidUpdateCart: Invalid arguments type');
      return null;
    }

    final totalAmountInCart = arguments['totalAmountInCart'] as int?;
    // Method channel provides List<dynamic>, need to convert to List<String>
    final clientOrderIDsDynamic = arguments['clientOrderIDs'] as List<dynamic>?;
    final clientOrderIDs = clientOrderIDsDynamic?.map((e) => e as String).toList();

    if (totalAmountInCart == null || clientOrderIDs == null) {
      debugPrint('orderingDidUpdateCart: Missing required fields');
      return null;
    }

    final cart = IaCart(
      totalAmountInCart: totalAmountInCart,
      clientOrderIDs: clientOrderIDs,
    );

    // Call the callback (fire and forget)
    try {
      callback(cart);
      return null;
    } catch (e) {
      debugPrint('orderingDidUpdateCart: Error calling callback: $e');
      return null;
    }
  }
}
