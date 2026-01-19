part of 'impl.dart';

enum _Views with IaBaseViews implements IaBaseViews {
  todo,
  ;

  @override
  String get viewId {
    return name;
  }
}
