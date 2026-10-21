part of '../core.dart';

enum _Views with IaBaseViews implements IaBaseViews {
  startScreen,
  apofinderScreen,
  ;

  @override
  String get viewId {
    return name;
  }
}
