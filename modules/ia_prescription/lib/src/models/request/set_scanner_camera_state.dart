part of '../../impl.dart';

class _RequestModelSetScannerCameraState implements IaBaseRequest {
  _RequestModelSetScannerCameraState({
    this.isOn,
    this.isFlashlightOn,
    this.isPreviewPaused,
  });

  final bool? isOn;

  final bool? isFlashlightOn;

  final bool? isPreviewPaused;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'isOn': isOn,
      'isFlashlightOn': isFlashlightOn,
      'isPreviewPaused': isPreviewPaused,
    };
  }
}
