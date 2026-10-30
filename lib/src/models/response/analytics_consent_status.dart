part of '../../core.dart';

/// The user's answer to the analytics question on the SDK's legal screen or "Datenverarbeitung" screen.
///
/// Read it with [IaSdk.getAnalyticsConsentStatus] and set it with [IaSdk.setAnalyticsConsentStatus].
///
enum IaSdkAnalyticsConsentStatus {
  /// The user hasn't answered yet, so the legal screen asks.
  ///
  notAnswered,

  /// The user accepted analytics, so the SDK logs events.
  ///
  accepted,

  /// The user declined analytics, so the SDK logs no events.
  ///
  declined,
}
