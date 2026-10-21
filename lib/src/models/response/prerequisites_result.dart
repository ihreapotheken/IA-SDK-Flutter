part of '../../core.dart';

/// Outcome of the prerequisites flow, returned by [IaSdk.launchPrerequisiteFlow].
///
class IaSdkPrerequisitesResult {
  /// Constructs a new instance of the [IaSdkPrerequisitesResult] object.
  ///
  const IaSdkPrerequisitesResult({
    required this.isCancelled,
  });

  /// Whether the user cancelled the flow.
  ///
  /// When it's `false`, the prerequisites are completed and a pharmacy is selected, unless
  /// [IaPrerequisitesConfiguration.runApofinderIfNeeded] is `false`.
  ///
  final bool isCancelled;
}
