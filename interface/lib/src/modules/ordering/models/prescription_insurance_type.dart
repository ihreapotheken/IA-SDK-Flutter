part of '_models.dart';

/// Insurance type classification for PDF prescriptions.
///
enum IaPrescriptionInsuranceType {
  /// Private health insurance prescription.
  ///
  privateInsurance,

  /// Public/statutory health insurance prescription.
  ///
  publicHealthcare;

  /// Returns the raw string value for native communication.
  ///
  String get rawValue {
    switch (this) {
      case IaPrescriptionInsuranceType.privateInsurance:
        return 'privateInsurance';
      case IaPrescriptionInsuranceType.publicHealthcare:
        return 'publicHealthcare';
    }
  }

  /// Creates an instance from a raw string value.
  ///
  static IaPrescriptionInsuranceType fromRawValue(String rawValue) {
    switch (rawValue) {
      case 'privateInsurance':
        return IaPrescriptionInsuranceType.privateInsurance;
      case 'publicHealthcare':
        return IaPrescriptionInsuranceType.publicHealthcare;
      default:
        throw ArgumentError('Unknown insurance type: $rawValue');
    }
  }
}
