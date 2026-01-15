part of 'impl.dart';

enum _Views with IaBaseViews implements IaBaseViews {
  searchScreen,
  ;

  @override
  String get viewId {
    return name;
  }
}
