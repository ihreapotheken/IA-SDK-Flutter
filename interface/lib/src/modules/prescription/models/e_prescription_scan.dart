part of '_models.dart';

/// E-prescription (eRezept) QR code scanned in the SDK prescription scanner.
///
class IaModelPrescriptionEPrescriptionScan {
  /// Constructs a new instance of the [IaModelPrescriptionEPrescriptionScan] object.
  ///
  const IaModelPrescriptionEPrescriptionScan({
    required this.rawCode,
    required this.urls,
  });

  /// Raw content of the scanned QR code.
  ///
  final String rawCode;

  /// Prescription task URLs contained in the code, one per prescription.
  ///
  final List<String> urls;
}
