part of 'impl.dart';

enum _Methods with IaBaseMethods implements IaBaseMethods {
  clearProductGridCache,
  ;

  @override
  String get methodId {
    return name;
  }

  @override
  Type? get argumentType {
    switch (this) {
      default:
        return null;
    }
  }
}
