part of 'impl.dart';

enum _Views with IaBaseViews implements IaBaseViews {
  redeemPrescription,
  ;

  @override
  String get viewId {
    return name;
  }
}
