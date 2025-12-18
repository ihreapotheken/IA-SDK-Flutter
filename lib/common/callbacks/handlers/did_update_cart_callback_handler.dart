import 'package:appsdk_v2_flutter_plugin/common/entities/ordering/ia_cart.dart';
import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/foundation.dart';

class DidUpdateCartCallbackHandler {
  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    // Check if callback is set first - no point processing if host app isn't listening
    final callback = publicApi.callbacks.onDidUpdateCart;
    if (callback == null) {
      return null;
    }

    // Extract cart from arguments
    if (arguments is! Map) {
      debugPrint('didUpdateCart: Invalid arguments type');
      return null;
    }

    try {
      // Convert Map<Object?, Object?> to Map<String, dynamic>
      final argumentsMap = Map<String, dynamic>.from(arguments);
      final cart = IaCart.fromJson(argumentsMap);

      // Call the callback (fire and forget)
      callback(cart);
      return null;
    } catch (e) {
      debugPrint('didUpdateCart: Error processing cart: $e');
      return null;
    }
  }
}
