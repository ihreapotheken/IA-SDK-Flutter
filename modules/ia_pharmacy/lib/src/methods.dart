part of 'impl.dart';

enum _Methods with IaBaseMethods implements IaBaseMethods {
  setPharmacyId,
  savePharmacyId,
  getPharmacyId,
  clearPharmacyId,
  getPharmacy,
  ;

  @override
  String get methodId {
    return name;
  }

  @override
  Type? get argumentType {
    switch (this) {
      case _Methods.setPharmacyId:
      case _Methods.savePharmacyId:
        return _RequestModelSetPharmacy;
      case _Methods.getPharmacy:
        return _RequestModelGetPharmacy;
      default:
        return null;
    }
  }
}
