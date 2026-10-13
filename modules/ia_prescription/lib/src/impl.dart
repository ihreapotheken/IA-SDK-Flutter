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
  /// Constructs the module and makes it the receiver of native prescription scan callbacks.
  ///
  IaModulePrescription() {
    _instance = this;
  }

  /// The most recently constructed module, which the native scan callbacks are routed to.
  ///
  static IaModulePrescription? _instance;

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
