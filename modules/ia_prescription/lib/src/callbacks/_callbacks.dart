part of '../impl.dart';

enum _Callbacks implements IaBaseCallbackHandler {
  prescriptionPhotoScanned,
  ePrescriptionScanned,
  prescriptionScannerCameraError,
  ;

  @override
  String get methodId {
    return name;
  }

  @override
  Future<dynamic> Function(dynamic args) get handler {
    return switch (this) {
      _Callbacks.prescriptionPhotoScanned => _prescriptionPhotoScannedHandler,
      _Callbacks.ePrescriptionScanned => _ePrescriptionScannedHandler,
      _Callbacks.prescriptionScannerCameraError => _scannerCameraErrorHandler,
    };
  }
}
