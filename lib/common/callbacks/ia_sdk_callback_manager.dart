part of '../../sdk.dart';


enum IaSdkCallbackManager {
  didFinishOrder,
  shouldOverrideRoute;

  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    switch (this) {
      case IaSdkCallbackManager.didFinishOrder:
        return DidFinishOrderCallbackHandler().handle<T>(arguments, publicApi);
      case IaSdkCallbackManager.shouldOverrideRoute:
        return ShouldOverrideRouteCallbackHandler().handle<T>(arguments, publicApi);
    }
  }
}
