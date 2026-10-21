part of '../core.dart';

/// User consent for the SDK's analytics tracking.
///
enum IaSdkAnalyticsConsent {
  /// The user agreed to analytics tracking.
  ///
  granted,

  /// The user declined analytics tracking.
  ///
  denied,

  /// The user hasn't decided yet.
  ///
  unknown,
}
