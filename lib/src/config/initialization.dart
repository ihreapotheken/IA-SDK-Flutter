part of '../core.dart';

/// Configuration options for SDK prerequisites.
///
class IaPrerequisitesConfiguration {
  /// Generates an instance of prerequisites configuration.
  ///
  const IaPrerequisitesConfiguration({
    this.isCancellable = false,
    this.isAnimated = true,
    this.runLegalIfNeeded = true,
    this.runOnboardingIfNeeded = true,
    this.runApofinderIfNeeded = true,
  });

  /// Whether the prerequisites flow can be cancelled.
  ///
  final bool isCancellable;

  /// Whether to show animations during prerequisites flow.
  ///
  final bool isAnimated;

  /// Whether to run legal documents flow if needed.
  ///
  final bool runLegalIfNeeded;

  /// Whether to run onboarding flow if needed.
  ///
  final bool runOnboardingIfNeeded;

  /// Whether to run pharmacy finder (Apofinder) flow if needed.
  ///
  final bool runApofinderIfNeeded;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'isCancellable': isCancellable,
      'isAnimated': isAnimated,
      'runLegalIfNeeded': runLegalIfNeeded,
      'runOnboardingIfNeeded': runOnboardingIfNeeded,
      'runApofinderIfNeeded': runApofinderIfNeeded,
    };
  }
}

/// Configuration options for SDK initialization behavior.
///
class IaSdkConfigurationInitialization {
  /// Generates an instance of initialization configuration.
  ///
  const IaSdkConfigurationInitialization({
    this.shouldShowIndicator = true,
    this.prerequisites = const IaPrerequisitesConfiguration(),
  });

  /// Whether to show a loading indicator during initialization.
  ///
  final bool shouldShowIndicator;

  /// Prerequisites configuration options.
  ///
  final IaPrerequisitesConfiguration prerequisites;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'shouldShowIndicator': shouldShowIndicator,
      'prerequisites': prerequisites.toJson(),
    };
  }
}
