import 'dart:async';
import 'dart:typed_data';

import 'package:ia_interface/ia_interface.dart';

part 'methods.dart';
part 'views.dart';
part 'callbacks/_callbacks.dart';
part 'callbacks/prescription_scanned.dart';
part 'callbacks/scanner_camera_error.dart';
part 'models/request/set_scanner_camera_state.dart';

/// Method and property definitions for the ia.de AppSDK Prescription service.
///
class IaModulePrescription extends IaBasePrescription {
  /// The scan callbacks are shared by all instances, like the streams of the other modules, so a callback set on
  /// any instance (for example `IaSdk.instance.prescription`) receives the native scan callbacks.
  ///
  static Future<IaModelPrescriptionScanDecision> Function(Uint8List imageData)? _onPrescriptionPhotoScanned;

  static Future<IaModelPrescriptionScanDecision> Function(IaModelPrescriptionEPrescriptionScan scan)?
  _onEPrescriptionScanned;

  @override
  Future<IaModelPrescriptionScanDecision> Function(Uint8List imageData)? get onPrescriptionPhotoScanned {
    return _onPrescriptionPhotoScanned;
  }

  @override
  set onPrescriptionPhotoScanned(Future<IaModelPrescriptionScanDecision> Function(Uint8List imageData)? callback) {
    _onPrescriptionPhotoScanned = callback;
  }

  @override
  Future<IaModelPrescriptionScanDecision> Function(IaModelPrescriptionEPrescriptionScan scan)?
  get onEPrescriptionScanned {
    return _onEPrescriptionScanned;
  }

  @override
  set onEPrescriptionScanned(
    Future<IaModelPrescriptionScanDecision> Function(IaModelPrescriptionEPrescriptionScan scan)? callback,
  ) {
    _onEPrescriptionScanned = callback;
  }

  @override
  Future<void> launchRedeemPrescriptionScreen() async {
    return await _Views.redeemPrescription.launch();
  }

  @override
  Future<void> launchPrescriptionScanner(IaPrescriptionScannerType type) async {
    return await switch (type) {
      IaPrescriptionScannerType.prescription => _Views.prescriptionScanner,
      IaPrescriptionScannerType.ePrescription => _Views.ePrescriptionScanner,
    }.launch();
  }

  @override
  Future<void> setScannerCameraState({
    bool? isOn,
    bool? isFlashlightOn,
    bool? isPreviewPaused,
  }) async {
    final arguments = _RequestModelSetScannerCameraState(
      isOn: isOn,
      isFlashlightOn: isFlashlightOn,
      isPreviewPaused: isPreviewPaused,
    );
    return await _Methods.setPrescriptionScannerCameraState.invoke<void>(arguments);
  }

  static final _scannerCameraErrorListener = StreamController<String>.broadcast();

  @override
  StreamController<String> get scannerCameraErrorListener {
    return _scannerCameraErrorListener;
  }

  @override
  final callbacks = IaBaseCallbacks(
    handlers: _Callbacks.values,
  );
}
