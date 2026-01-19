part of 'impl.dart';

enum _Views with IaBaseViews implements IaBaseViews {
  cartScreen,
  ;

  @override
  String get viewId {
    return name;
  }
}
