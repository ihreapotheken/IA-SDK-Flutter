import 'package:appsdk_v2_flutter_plugin/common/entities/ordering/ia_order.dart';
import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/foundation.dart';

class DidFinishOrderCallbackHandler {
  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    // Check if callback is set first - no point processing if host app isn't listening
    final callback = publicApi.callbacks.onDidFinishOrder;
    if (callback == null) {
      return null;
    }

    // Extract order info from arguments
    if (arguments is! Map) {
      debugPrint('didFinishOrder: Invalid arguments type');
      return null;
    }

    final orderCode = arguments['orderCode'] as String?;
    final clientOrderID = arguments['clientOrderID'] as String?;

    if (orderCode == null) {
      debugPrint('didFinishOrder: Missing orderCode');
      return null;
    }

    final order = IaOrder(
      orderCode: orderCode,
      clientOrderID: clientOrderID,
    );

    // Call the callback (fire and forget)
    try {
      callback(order);
      return null;
    } catch (e) {
      debugPrint('didFinishOrder: Error calling callback: $e');
      return null;
    }
  }
}
