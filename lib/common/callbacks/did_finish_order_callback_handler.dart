import 'package:appsdk_v2_flutter_plugin/common/entities/ia_order.dart';
import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/foundation.dart';

class DidFinishOrderCallbackHandler {
  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
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

    // Get the callback from the callbacks object
    final callback = publicApi.callbacks.onDidFinishOrder;
    if (callback == null) {
      // No callback set, just return
      debugPrint('didFinishOrder: No callback set');
      return null;
    }

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
