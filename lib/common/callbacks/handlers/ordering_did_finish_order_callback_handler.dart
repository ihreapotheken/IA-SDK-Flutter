import 'package:appsdk_v2_flutter_plugin/common/entities/ordering/ia_order.dart';
import 'package:appsdk_v2_flutter_plugin/modules/ia_sdk/ia_sdk.dart';
import 'package:flutter/foundation.dart';

class OrderingDidFinishOrderCallbackHandler {
  Future<T?> handle<T>(
    dynamic arguments,
    IaSdk iaSdk,
  ) async {
    // Check if callback is set first - no point processing if host app isn't listening
    final callback = iaSdk.callbacks.onOrderingDidFinishOrder;
    if (callback == null) {
      return null;
    }

    // Extract order info from arguments
    if (arguments is! Map) {
      debugPrint('orderingDidFinishOrder: Invalid arguments type');
      return null;
    }

    final orderCode = arguments['orderCode'] as String?;
    // Method channel provides List<dynamic>, need to convert to List<String>
    final clientOrderIDsDynamic = arguments['clientOrderIDs'] as List<dynamic>?;
    final clientOrderIDs = clientOrderIDsDynamic?.map((e) => e as String).toList();

    if (orderCode == null) {
      debugPrint('orderingDidFinishOrder: Missing orderCode');
      return null;
    }

    final order = IaOrder(
      orderCode: orderCode,
      clientOrderIDs: clientOrderIDs,
    );

    // Call the callback (fire and forget)
    try {
      callback(order);
      return null;
    } catch (e) {
      debugPrint('orderingDidFinishOrder: Error calling callback: $e');
      return null;
    }
  }
}
