part of '../ia_sdk_callback_manager.dart';

class _OrderingDidFinishOrderCallbackHandler implements _CallbackHandler {
  @override
  Future<void> handle(
    dynamic arguments,
    IaSdk iaSdk,
  ) async {
    // Check if callback is set first - no point processing if host app isn't listening
    final callback = iaSdk.callbacks.onOrderingDidFinishOrder;
    if (callback == null) {
      return;
    }

    // Extract order info from arguments
    if (arguments is! Map) {
      debugPrint('orderingDidFinishOrder: Invalid arguments type');
      return;
    }

    final orderCode = arguments['orderCode'] as String?;
    // Method channel provides List<dynamic>, need to convert to List<String>
    final clientOrderIDsDynamic = arguments['clientOrderIDs'] as List<dynamic>?;
    final clientOrderIDs = clientOrderIDsDynamic?.map((e) => e as String).toList();

    if (orderCode == null) {
      debugPrint('orderingDidFinishOrder: Missing orderCode');
      return;
    }

    final order = IaModelOrder(
      orderCode: orderCode,
      clientOrderIDs: clientOrderIDs,
    );

    // Call the callback (fire and forget)
    try {
      callback(order);
    } catch (e) {
      debugPrint('orderingDidFinishOrder: Error calling callback: $e');
    }
  }
}
