/// Decision for how the SDK should handle a particular action.
///
enum IaHandlingDecision {
  /// The host app has handled the action, SDK should not perform its default behavior.
  handled,

  /// The SDK should perform its default behavior.
  performDefault;

  factory IaHandlingDecision.fromRawValue(String value) {
    return switch (value) {
      'handled' => IaHandlingDecision.handled,
      'performDefault' => IaHandlingDecision.performDefault,
      _ => throw UnimplementedError(
        'IaHandlingDecision not defined for $value.',
      ),
    };
  }
}
