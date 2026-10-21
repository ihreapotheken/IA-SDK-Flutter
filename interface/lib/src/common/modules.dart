part of '_interface.dart';

/// SDK modules that can be registered for use in the application.
///
/// Each module provides specific functionality within the ia.de SDK.
///
enum IaBaseModule {
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

  /// Appointment booking functionality.
  ///
  /// On Android this registers the native `AppointmentsModule`. On iOS
  /// appointment booking is part of the Integrations module and is enabled
  /// through the pharmacy configuration, so no separate registration occurs.
  ///
  appointments,
}
