part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK Pharmacy service.
///
/// Members documented as "Only supported on iOS" or "Only supported on Android" throw a
/// [MissingPluginException] on the other platform.
///
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
  /// [pharmacyId] is the numeric pharmacy identifier, for example `"1234"`. iOS rejects other values.
  ///
  Future<void> setPharmacyId(String pharmacyId);

  /// Stores the pharmacy identifier without validating it or loading the pharmacy, unlike [setPharmacyId].
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> savePharmacyId(String pharmacyId);

  /// Returns the currently selected pharmacy identifier, or `null` if no pharmacy is selected.
  ///
  Future<String?> getPharmacyId();

  /// Clears the selected pharmacy, so [getPharmacyId] returns `null` until a pharmacy is selected again.
  ///
  Future<void> clearPharmacyId();

  /// Returns the details of the selected pharmacy, or `null` if no pharmacy is selected.
  ///
  /// With [allowCached] the SDK may return previously loaded details instead of loading them again.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<IaModelPharmacy?> getPharmacy({
    bool allowCached = true,
  });
}
