part of 'impl.dart';

enum _Views with IaBaseViews implements IaBaseViews {
  pharmacyScreen,
  ;

  @override
  String get viewId {
    return name;
  }
}
