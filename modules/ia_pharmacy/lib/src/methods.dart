part of 'impl.dart';

enum _Methods with IaBaseMethods implements IaBaseMethods {
  setPharmacyId,
  ;

  @override
  String get methodId {
    return name;
  }

  @override
  Type? get argumentType {
    switch (this) {
      case _Methods.setPharmacyId:
        return _RequestModelSetPharmacy;
      default:
        return null;
    }
  }
}
