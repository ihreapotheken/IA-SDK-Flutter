part of 'sdk.dart';

enum _IaPlatformCallbacks {
  didFinishOrder,
  shouldOverrideRoute;

  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    switch (this) {
      case _IaPlatformCallbacks.didFinishOrder:
        // TODO pass this info to host app
        return null;
      case _IaPlatformCallbacks.shouldOverrideRoute:
        // Extract route override from arguments
        if (arguments is! Map) {
          debugPrint('shouldOverrideRoute: Invalid arguments type');
          return IaHandlingDecision.performDefault._nativeValue as T?;
        }

        final routeOverrideString = arguments['routeOverride'] as String?;
        if (routeOverrideString == null) {
          debugPrint('shouldOverrideRoute: Missing routeOverride');
          return IaHandlingDecision.performDefault._nativeValue as T?;
        }

        final routeOverride = IaRouteOverride._fromNativeValue(routeOverrideString);
        if (routeOverride == null) {
          debugPrint('shouldOverrideRoute: Unknown routeOverride: $routeOverrideString');
          return IaHandlingDecision.performDefault._nativeValue as T?;
        }

        // Get the callback from the callbacks object
        final callback = publicApi.callbacks.onShouldOverrideRoute;
        if (callback == null) {
          // No callback set, always perform default
          return IaHandlingDecision.performDefault._nativeValue as T?;
        }

        // Call the callback
        try {
          final decision = await callback(routeOverride);
          return decision._nativeValue as T?;
        } catch (e) {
          debugPrint('shouldOverrideRoute: Error calling callback: $e');
          return IaHandlingDecision.performDefault._nativeValue as T?;
        }
    }
  }
}
