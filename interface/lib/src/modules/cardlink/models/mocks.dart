part of '_models.dart';

/// Simulated CardLink backend responses, for testing CardLink flows without a health card.
///
class IaCardLinkMocks {
  /// Constructs a new instance of the [IaCardLinkMocks] object.
  ///
  const IaCardLinkMocks({
    this.isMockingEnabled = true,
    this.sessionResponse = IaCardLinkSessionMockResponse.auto,
    this.sessionDuration,
    this.sessionWillExpireSoonInterval,
    this.verificationResponse = IaCardLinkVerificationMockResponse.success,
    this.ePrescriptionXmls,
    this.arePrescriptionsPartiallyMocked = false,
    this.isWrongCanMocked = false,
  });

  /// Whether the mocks are used. With `false` CardLink talks to the real backend.
  ///
  final bool isMockingEnabled;

  /// Response to session creation.
  ///
  final IaCardLinkSessionMockResponse sessionResponse;

  /// Duration of a mocked session. `null` keeps the SDK default.
  ///
  final Duration? sessionDuration;

  /// How long before the end of a mocked session it counts as expiring soon. `null` keeps the SDK default.
  ///
  final Duration? sessionWillExpireSoonInterval;

  /// Response to the SMS code verification.
  ///
  final IaCardLinkVerificationMockResponse verificationResponse;

  /// E-prescription XML documents returned instead of the card's prescriptions. `null` reads real prescriptions.
  ///
  final List<String>? ePrescriptionXmls;

  /// Whether only some of [ePrescriptionXmls] are returned, to test partially readable prescriptions.
  ///
  final bool arePrescriptionsPartiallyMocked;

  /// Whether scanning reports a wrong CAN.
  ///
  final bool isWrongCanMocked;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'isMockingEnabled': isMockingEnabled,
      'sessionResponse': sessionResponse.name,
      'sessionDurationSeconds': sessionDuration == null ? null : sessionDuration!.inMilliseconds / 1000,
      'sessionWillExpireSoonSeconds': sessionWillExpireSoonInterval == null ? null : sessionWillExpireSoonInterval!.inMilliseconds / 1000,
      'verificationResponse': verificationResponse.name,
      'ePrescriptionXmls': ePrescriptionXmls,
      'arePrescriptionsPartiallyMocked': arePrescriptionsPartiallyMocked,
      'isWrongCanMocked': isWrongCanMocked,
    };
  }
}

/// Simulated response to CardLink session creation, see [IaCardLinkMocks.sessionResponse].
///
enum IaCardLinkSessionMockResponse {
  /// The SDK picks the response that fits the flow.
  ///
  auto,

  /// An existing session is resumed.
  ///
  resumeSession,

  /// The phone number has to be verified.
  ///
  verificationNeeded,

  /// The phone number is rejected.
  ///
  wrongPhoneNumber,

  /// The service isn't available.
  ///
  serviceNotAvailable,

  /// Any other error.
  ///
  otherError,
}

/// Simulated response to the SMS code verification, see [IaCardLinkMocks.verificationResponse].
///
enum IaCardLinkVerificationMockResponse {
  /// The code is accepted.
  ///
  success,

  /// The code is wrong.
  ///
  wrongOtp,

  /// The code has expired.
  ///
  expiredOtp,

  /// Too many attempts.
  ///
  maxAttemptsReached,

  /// Any other error.
  ///
  otherError,
}
