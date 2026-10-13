part of '../../core.dart';

/// Outcome of the prerequisites flow, reported through [IaSdk.prerequisitesResultListener].
///
class IaSdkPrerequisitesResult {
  /// Constructs a new instance of the [IaSdkPrerequisitesResult] object.
  ///
  const IaSdkPrerequisitesResult({
    required this.isCancelled,
    this.onboarding,
    this.legal,
    this.pharmacyId,
  });

  /// Whether the user cancelled the flow.
  ///
  final bool isCancelled;

  /// Outcome of the onboarding step. Only reported on iOS.
  ///
  final IaSdkOnboardingResult? onboarding;

  /// Outcome of the legal documents step. Only reported on iOS.
  ///
  final IaSdkLegalResult? legal;

  /// Pharmacy the user selected, `null` if the selection was cancelled. Only reported on iOS.
  ///
  final String? pharmacyId;
}

/// Outcome of the onboarding step of the prerequisites flow.
///
enum IaSdkOnboardingResult {
  /// The onboarding wasn't shown, for example because it was already completed.
  ///
  notStarted,

  /// There's no onboarding content to show.
  ///
  noOnboardingData,

  /// The user finished the onboarding.
  ///
  finished,

  /// The user cancelled the onboarding.
  ///
  cancelled,
}

/// Outcome of the legal documents step of the prerequisites flow.
///
enum IaSdkLegalResult {
  /// The user accepted the legal documents.
  ///
  accepted,

  /// The user cancelled.
  ///
  cancelled,

  /// The legal documents weren't shown, for example because they were already accepted.
  ///
  notStarted,

  /// There are no legal documents to show.
  ///
  noLegalTextFound,
}
