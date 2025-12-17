import 'package:appsdk_v2_flutter_plugin/common/entities/ia_cart_state.dart';
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

    // Extract cart state from arguments
    if (arguments is! Map) {
      debugPrint('didUpdateCart: Invalid arguments type');
      return null;
    }

    try {
      final cartState = IaCartState.fromJson(arguments as Map<String, dynamic>);

      // Call the callback (fire and forget)
      callback(cartState);
      return null;
    } catch (e) {
      debugPrint('didUpdateCart: Error processing cart state: $e');
      return null;
    }
  }
}
