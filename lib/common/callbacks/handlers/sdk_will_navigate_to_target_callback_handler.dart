import 'package:appsdk_v2_flutter_plugin/common/entities/ia_handling_decision.dart';
import 'package:appsdk_v2_flutter_plugin/common/entities/ia_sdk_navigation_target.dart';
import 'package:appsdk_v2_flutter_plugin/features/ia_sdk/ia_sdk.dart';
import 'package:flutter/foundation.dart';

class SdkWillNavigateToTargetCallbackHandler {
  Future<T?> handle<T>(
    dynamic arguments,
    IaSdk iaSdk,
  ) async {
    // Check if callback is set first - no point processing if host app isn't listening
    final callback = iaSdk.callbacks.onSdkWillNavigateToTarget;
    if (callback == null) {
      // No callback set, always perform default
      return IaHandlingDecision.performDefault.rawValue as T?;
    }

    // Extract navigation target from arguments
    if (arguments is! Map) {
      debugPrint('sdkWillNavigateToTarget: Invalid arguments type');
      return IaHandlingDecision.performDefault.rawValue as T?;
    }

    final navigationTargetString = arguments['navigationTarget'] as String?;
    if (navigationTargetString == null) {
      debugPrint('sdkWillNavigateToTarget: Missing navigationTarget');
      return IaHandlingDecision.performDefault.rawValue as T?;
    }

    final navigationTarget = IaSdkNavigationTarget.fromRawValue(navigationTargetString);
    if (navigationTarget == null) {
      debugPrint('sdkWillNavigateToTarget: Unknown navigationTarget: $navigationTargetString');
      return IaHandlingDecision.performDefault.rawValue as T?;
    }

    // Call the callback
    try {
      final decision = await callback(navigationTarget);
      return decision.rawValue as T?;
    } catch (e) {
      debugPrint('sdkWillNavigateToTarget: Error calling callback: $e');
      return IaHandlingDecision.performDefault.rawValue as T?;
    }
  }
}
