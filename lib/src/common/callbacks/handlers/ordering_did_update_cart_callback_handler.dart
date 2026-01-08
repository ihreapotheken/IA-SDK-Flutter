part of '../ia_sdk_callback_manager.dart';

class _OrderingDidUpdateCartCallbackHandler implements _CallbackHandler {
  @override
  Future<void> handle(
    dynamic arguments,
    IaSdk iaSdk,
  ) async {
    // Check if callback is set first - no point processing if host app isn't listening
    final callback = iaSdk.callbacks.onOrderingDidUpdateCart;
    if (callback == null) {
      return;
    }

    // Extract cart info from arguments
    if (arguments is! Map) {
      debugPrint('orderingDidUpdateCart: Invalid arguments type');
      return;
    }

    final totalAmountInCart = arguments['totalAmountInCart'] as int?;
    // Method channel provides List<dynamic>, need to convert to List<String>
    final clientOrderIDsDynamic = arguments['clientOrderIDs'] as List<dynamic>?;
    final clientOrderIDs = clientOrderIDsDynamic?.map((e) => e as String).toList();

    if (totalAmountInCart == null || clientOrderIDs == null) {
      debugPrint('orderingDidUpdateCart: Missing required fields');
      return;
    }

    final cart = IaModelCart(
      totalAmountInCart: totalAmountInCart,
      clientOrderIDs: clientOrderIDs,
    );

    // Call the callback (fire and forget)
    try {
      callback(cart);
    } catch (e) {
      debugPrint('orderingDidUpdateCart: Error calling callback: $e');
    }
  }
}
