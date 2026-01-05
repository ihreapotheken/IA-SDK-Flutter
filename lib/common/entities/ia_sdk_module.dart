/// SDK modules that can be registered for use in the application.
///
/// Each module provides specific functionality within the ia.de SDK.
///
enum IaSdkModule {
  /// Integrations, mandatory module.
  ///
  integrations,

  /// Over-the-counter product browsing and purchasing functionality.
  ///
  overTheCounter,

  /// Order management and checkout functionality.
  ///
  ordering,

  /// Pharmacy finder (Apofinder) functionality for locating and selecting pharmacies.
  ///
  apofinder,

  /// Detailed pharmacy information display.
  ///
  pharmacyDetails,

  /// Prescription management functionality including scanning and uploading.
  ///
  prescription,

  /// CardLink (NFC) prescription transfer functionality.
  ///
  cardLink,
}
