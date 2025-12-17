import 'package:appsdk_v2_flutter_plugin/common/entities/ia_handling_decision.dart';
import 'package:appsdk_v2_flutter_plugin/common/entities/ia_route_override.dart';
import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/foundation.dart';

class ShouldOverrideRouteCallbackHandler {
  Future<T?> handle<T>(
    dynamic arguments,
    IaSdkApi publicApi,
  ) async {
    // Check if callback is set first - no point processing if host app isn't listening
    final callback = publicApi.callbacks.onShouldOverrideRoute;
    if (callback == null) {
      // No callback set, always perform default
      return IaHandlingDecision.performDefault.rawValue as T?;
    }

    // Extract route override from arguments
    if (arguments is! Map) {
      debugPrint('shouldOverrideRoute: Invalid arguments type');
      return IaHandlingDecision.performDefault.rawValue as T?;
    }

    final routeOverrideString = arguments['routeOverride'] as String?;
    if (routeOverrideString == null) {
      debugPrint('shouldOverrideRoute: Missing routeOverride');
      return IaHandlingDecision.performDefault.rawValue as T?;
    }

    final routeOverride = IaRouteOverride.fromRawValue(routeOverrideString);
    if (routeOverride == null) {
      debugPrint('shouldOverrideRoute: Unknown routeOverride: $routeOverrideString');
      return IaHandlingDecision.performDefault.rawValue as T?;
    }

    // Call the callback
    try {
      final decision = await callback(routeOverride);
      return decision.rawValue as T?;
    } catch (e) {
      debugPrint('shouldOverrideRoute: Error calling callback: $e');
      return IaHandlingDecision.performDefault.rawValue as T?;
    }
  }
}
