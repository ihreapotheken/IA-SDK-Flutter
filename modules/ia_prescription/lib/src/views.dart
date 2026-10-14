part of 'impl.dart';

enum _Views with IaBaseViews implements IaBaseViews {
  redeemPrescription,
  prescriptionScanner,
  ePrescriptionScanner,
  ;

  @override
  String get viewId {
    return name;
  }
}
