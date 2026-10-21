part of 'impl.dart';

enum _Methods with IaBaseMethods implements IaBaseMethods {
  setPrescriptionScannerCameraState,
  ;

  @override
  String get methodId {
    return name;
  }

  @override
  Type? get argumentType {
    switch (this) {
      case _Methods.setPrescriptionScannerCameraState:
        return _RequestModelSetScannerCameraState;
    }
  }
}
