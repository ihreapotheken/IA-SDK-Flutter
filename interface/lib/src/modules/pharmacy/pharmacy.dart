part of '../../common/_interface.dart';

abstract class IaBasePharmacy extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.pharmacyDetails;
  }

  /// Launches the pharmacy details screen experience on top of the navigation stack.
  ///
  Future<void> launchPharmacyDetails();

  /// Specifies a pharmacy identifier to be loaded into the AppSDK module for user interaction.
  ///
  Future<void> setPharmacyId(String pharmacyId);
}
