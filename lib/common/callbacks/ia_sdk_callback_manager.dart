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
        // TODO pass this info to host app
        return null;
      case IaSdkCallbackManager.shouldOverrideRoute:
        return ShouldOverrideRouteCallbackHandler().handle<T>(arguments, publicApi);
    }
  }
}
