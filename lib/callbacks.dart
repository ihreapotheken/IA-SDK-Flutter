part of 'sdk.dart';

enum _IaPlatformCallbacks {
  didFinishOrder;

  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    switch (this) {
      case _IaPlatformCallbacks.didFinishOrder:
        // TODO pass this info to host app
        return null;
    }
  }
}
