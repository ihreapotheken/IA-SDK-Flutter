part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK Pharmacy service.
///
/// Methods documented as "Only supported on iOS" or "Only supported on Android" throw a
/// [MissingPluginException] on the other platform. Callbacks and streams with such a note never fire there.
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
  /// [pharmacyId] is the numeric pharmacy identifier, for example `"1234"`. Both platforms reject other values.
  ///
  /// On Android, call it after `IaSdk.initialize`; before that the call fails.
  ///
  Future<void> setPharmacyId(String pharmacyId);

  /// Stores the pharmacy identifier without checking that the pharmacy exists or loading it, unlike [setPharmacyId].
  ///
  /// [pharmacyId] is the numeric pharmacy identifier; other values are rejected.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> savePharmacyId(String pharmacyId);

  /// Returns the currently selected pharmacy identifier, or `null` if no pharmacy is selected.
  ///
  /// On Android, call it after `IaSdk.initialize`; before that the call fails, since the SDK can't read the stored
  /// identifier yet.
  ///
  Future<String?> getPharmacyId();

  /// Clears the selected pharmacy, so [getPharmacyId] returns `null` until a pharmacy is selected again.
  ///
  /// On Android, call it after `IaSdk.initialize`; before that the call fails.
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
