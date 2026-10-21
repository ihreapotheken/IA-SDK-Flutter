part of '_models.dart';

/// Kind of prescription the SDK scanner captures.
///
enum IaPrescriptionScannerType {
  /// Photo of a paper prescription.
  ///
  prescription,

  /// E-prescription (eRezept) QR code.
  ///
  ePrescription,
}
