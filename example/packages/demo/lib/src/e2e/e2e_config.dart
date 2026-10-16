/// Build-time configuration for the E2E test harness.
///
/// The harness replaces the regular demo UI with a minimal host that mirrors
/// the native demo apps (IA-SDK-Dev-Android / IA-SDK-Dev-iOS), so the shared
/// e2e-tests suite can drive the Flutter example app with the same flows.
///
/// Enable it at build time:
///
/// ```sh
/// flutter build apk --debug --dart-define=iaE2E=true
/// flutter build ios --simulator --dart-define=iaE2E=true
/// ```
///
class E2EConfig {
  const E2EConfig._();

  /// Whether the app should boot into the E2E harness instead of the demo UI.
  ///
  static const bool enabled = bool.fromEnvironment('iaE2E');

  /// Optional pharmacy to pre-select before the harness is shown, e.g.
  /// `--dart-define=iaE2EPharmacyId=2163`.
  ///
  /// Left empty by default so the SDK's Apofinder prerequisite runs and the
  /// test drives pharmacy selection itself — matching the native demo flows.
  ///
  static const String pharmacyId = String.fromEnvironment('iaE2EPharmacyId');
}
