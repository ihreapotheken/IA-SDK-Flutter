part of '../../sdk.dart';

enum IaSdkCallbackManager {
  orderingDidFinishOrder,
  orderingDidUpdateCart,
  sdkWillNavigateToTarget;

  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    switch (this) {
      case IaSdkCallbackManager.orderingDidFinishOrder:
        return OrderingDidFinishOrderCallbackHandler().handle<T>(arguments, publicApi);
      case IaSdkCallbackManager.orderingDidUpdateCart:
        return OrderingDidUpdateCartCallbackHandler().handle<T>(arguments, publicApi);
      case IaSdkCallbackManager.sdkWillNavigateToTarget:
        return SdkWillNavigateToTargetCallbackHandler().handle<T>(arguments, publicApi);
    }
  }
}
