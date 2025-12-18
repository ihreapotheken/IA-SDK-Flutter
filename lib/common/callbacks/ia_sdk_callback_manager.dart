part of '../../sdk.dart';

enum IaSdkCallbackManager {
  orderingDidFinishOrders,
  orderingDidUpdateCart,
  shouldOverrideRoute;

  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    switch (this) {
      case IaSdkCallbackManager.orderingDidFinishOrders:
        return OrderingDidFinishOrdersCallbackHandler().handle<T>(arguments, publicApi);
      case IaSdkCallbackManager.orderingDidUpdateCart:
        return OrderingDidUpdateCartCallbackHandler().handle<T>(arguments, publicApi);
      case IaSdkCallbackManager.shouldOverrideRoute:
        return ShouldOverrideRouteCallbackHandler().handle<T>(arguments, publicApi);
    }
  }
}
