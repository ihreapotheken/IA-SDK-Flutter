part of '../../features/ia_sdk/ia_sdk.dart';

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
        return OrderingDidFinishOrderCallbackHandler().handle<T>(arguments, iaSdk);
      case IaSdkCallbackManager.orderingDidUpdateCart:
        return OrderingDidUpdateCartCallbackHandler().handle<T>(arguments, iaSdk);
      case IaSdkCallbackManager.sdkWillNavigateToTarget:
        return SdkWillNavigateToTargetCallbackHandler().handle<T>(arguments, iaSdk);
    }
  }
}
