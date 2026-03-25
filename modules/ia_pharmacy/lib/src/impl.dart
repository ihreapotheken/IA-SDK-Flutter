import 'package:ia_interface/ia_interface.dart';

part 'methods.dart';
part 'views.dart';
part 'models/request/set_pharmacy.dart';

/// Method and property definitions for the ia.de AppSDK Pharmacy service.
///
class IaModulePharmacy extends IaBasePharmacy {
  @override
  Future<void> launchPharmacyDetails() async {
    return await _Views.pharmacyScreen.launch();
  }

  @override
  Future<void> setPharmacyId(
    String pharmacyId,
  ) async {
    final arguments = _RequestModelSetPharmacy(
      pharmacyId: pharmacyId,
    );
    return await _Methods.setPharmacyId.invoke<void>(arguments);
  }

  @override
  Future<String?> getPharmacyId() async {
    return await _Methods.getPharmacyId.invoke<String?>(null);
  }
}
