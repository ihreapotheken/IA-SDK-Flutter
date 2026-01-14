part of 'impl.dart';

enum _Views with IaBaseViews implements IaBaseViews {
  pharmacyDetailsScreen,
  ;

  @override
  String get viewId {
    return name;
  }
}
