import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin/src/features/ia_ordering/ordering/ia_cart.dart';
import 'package:appsdk_v2_flutter_plugin/src/features/ia_ordering/ordering/ia_order.dart';
import 'package:flutter/material.dart';

part 'handlers/_handler.dart';
part 'handlers/ordering_did_finish_order_callback_handler.dart';
part 'handlers/ordering_did_update_cart_callback_handler.dart';
part 'handlers/sdk_will_navigate_to_target_callback_handler.dart';

enum IaSdkCallbackManager {
  orderingDidFinishOrder,
  orderingDidUpdateCart,
  sdkWillNavigateToTarget;

  Future<T?> handle<T>(
    dynamic arguments,
    IaSdk iaSdk,
  ) async {
    switch (this) {
      case IaSdkCallbackManager.orderingDidFinishOrder:
        return _OrderingDidFinishOrderCallbackHandler().handle(arguments, iaSdk) as Future<T?>;
      case IaSdkCallbackManager.orderingDidUpdateCart:
        return _OrderingDidUpdateCartCallbackHandler().handle(arguments, iaSdk) as Future<T?>;
      case IaSdkCallbackManager.sdkWillNavigateToTarget:
        return _SdkWillNavigateToTargetCallbackHandler().handle(arguments, iaSdk) as Future<T?>;
    }
  }
}
