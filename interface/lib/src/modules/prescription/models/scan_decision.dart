part of '_models.dart';

/// Tells the SDK how to continue after the host app received a scanned prescription.
///
class IaModelPrescriptionScanDecision {
  const IaModelPrescriptionScanDecision._(this._decision, [this.message]);

  /// The SDK continues with its built-in handling of the scanned prescription.
  ///
  static const performDefault = IaModelPrescriptionScanDecision._('performDefault');

  /// The host app has taken over the scanned prescription, so the SDK does nothing further with it.
  ///
  /// The scanner stays open and resumes scanning, so the host app closes it when it's done.
  ///
  static const handled = IaModelPrescriptionScanDecision._('handled');

  /// The host app rejects the scanned prescription, and the SDK reports [message] as the error.
  ///
  const IaModelPrescriptionScanDecision.error(String message) : this._('error', message);

  /// Native identifier of the decision.
  ///
  final String _decision;

  /// Error message, only set for [IaModelPrescriptionScanDecision.error].
  ///
  final String? message;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'decision': _decision,
      'message': message,
    };
  }
}
