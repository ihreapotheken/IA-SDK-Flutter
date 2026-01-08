part of '../ia_sdk_callback_manager.dart';

class _SdkWillNavigateToTargetCallbackHandler implements _CallbackHandler {
  @override
  Future<String> handle(
    dynamic arguments,
    IaSdk iaSdk,
  ) async {
    // Check if callback is set first - no point processing if host app isn't listening
    final callback = iaSdk.callbacks.onSdkWillNavigateToTarget;
    if (callback == null) {
      // No callback set, always perform default
      return IaHandlingDecision.performDefault.name;
    }

    // Extract navigation target from arguments
    if (arguments is! Map) {
      debugPrint('sdkWillNavigateToTarget: Invalid arguments type');
      return IaHandlingDecision.performDefault.name;
    }

    final navigationTargetString = arguments['navigationTarget'] as String?;
    if (navigationTargetString == null) {
      debugPrint('sdkWillNavigateToTarget: Missing navigationTarget');
      return IaHandlingDecision.performDefault.name;
    }

    final navigationTarget = IaSdkNavigationTarget.fromRawValue(navigationTargetString);
    if (navigationTarget == null) {
      debugPrint('sdkWillNavigateToTarget: Unknown navigationTarget: $navigationTargetString');
      return IaHandlingDecision.performDefault.name;
    }

    // Call the callback
    try {
      final decision = await callback(navigationTarget);
      return decision.name;
    } catch (e) {
      debugPrint('sdkWillNavigateToTarget: Error calling callback: $e');
      return IaHandlingDecision.performDefault.name;
    }
  }
}
