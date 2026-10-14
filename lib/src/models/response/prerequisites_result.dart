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
  /// The steps after a cancelled one don't run, and iOS reports them as cancelled too, with a `null` [pharmacyId].
  ///
  final bool isCancelled;

  /// Outcome of the onboarding step. Only reported on iOS.
  ///
  final IaSdkOnboardingResult? onboarding;

  /// Outcome of the legal documents step. Only reported on iOS.
  ///
  final IaSdkLegalResult? legal;

  /// Pharmacy after the flow: the one the user selected, or the stored one when it's still valid and no selection was
  /// needed. `null` if the user closed the pharmacy selection. Only reported on iOS.
  ///
  final String? pharmacyId;
}

/// Outcome of the onboarding step of the prerequisites flow.
///
enum IaSdkOnboardingResult {
  /// The onboarding step wasn't part of the flow, as the prerequisites options don't run it.
  ///
  notStarted,

  /// There's no onboarding content to show.
  ///
  noOnboardingData,

  /// The onboarding is done: the user finished it now, or it was already shown before.
  ///
  finished,

  /// The user cancelled the onboarding.
  ///
  cancelled,
}

/// Outcome of the legal documents step of the prerequisites flow.
///
enum IaSdkLegalResult {
  /// The legal documents are accepted: by the user now, or already before.
  ///
  accepted,

  /// The user cancelled.
  ///
  cancelled,

  /// The legal documents step wasn't part of the flow, as the prerequisites options don't run it.
  ///
  notStarted,

  /// There are no legal documents to show.
  ///
  noLegalTextFound,
}
