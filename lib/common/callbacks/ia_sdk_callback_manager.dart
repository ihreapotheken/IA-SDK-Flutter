part of '../../sdk.dart';

enum IaSdkCallbackManager {
  didFinishOrder,
  didUpdateCart,
  shouldOverrideRoute;

  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    switch (this) {
      case IaSdkCallbackManager.didFinishOrder:
        return DidFinishOrderCallbackHandler().handle<T>(arguments, publicApi);
      case IaSdkCallbackManager.didUpdateCart:
        return DidUpdateCartCallbackHandler().handle<T>(arguments, publicApi);
      case IaSdkCallbackManager.shouldOverrideRoute:
        return ShouldOverrideRouteCallbackHandler().handle<T>(arguments, publicApi);
    }
  }
}
