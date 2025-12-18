part of '../../sdk.dart';

enum IaSdkCallbackManager {
  orderingDidFinishOrders,
  didUpdateCart,
  shouldOverrideRoute;

  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    switch (this) {
      case IaSdkCallbackManager.orderingDidFinishOrders:
        return OrderingDidFinishOrdersCallbackHandler().handle<T>(arguments, publicApi);
      case IaSdkCallbackManager.didUpdateCart:
        return DidUpdateCartCallbackHandler().handle<T>(arguments, publicApi);
      case IaSdkCallbackManager.shouldOverrideRoute:
        return ShouldOverrideRouteCallbackHandler().handle<T>(arguments, publicApi);
    }
  }
}
