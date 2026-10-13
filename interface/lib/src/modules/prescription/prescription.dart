part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK Prescription service.
///
abstract class IaBasePrescription extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.prescription;
  }

  /// Launches the "redeem prescription" screen on top of the navigation stack.
  ///
  /// The screen lets the user choose how to add a prescription to the cart
  /// (for example by scanning a QR code, photographing a prescription, or via
  /// CardLink), depending on which capabilities are enabled.
  ///
  Future<void> launchRedeemPrescriptionScreen();

  /// Launches the prescription scanner for the given [type] directly, without the "redeem prescription" screen.
  ///
  /// Scanned prescriptions are reported through [onPrescriptionPhotoScanned] and [onEPrescriptionScanned].
  ///
  /// Note: Only supported on iOS. On Android open the scanner from [launchRedeemPrescriptionScreen].
  ///
  Future<void> launchPrescriptionScanner(IaPrescriptionScannerType type);

  /// Controls the camera of the scanner opened with [launchPrescriptionScanner]. `null` values stay unchanged.
  ///
  /// Each scanner launch starts with the camera on, the flashlight off and the preview running.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> setScannerCameraState({
    bool? isOn,
    bool? isFlashlightOn,
    bool? isPreviewPaused,
  });

  /// Notifier object informing the client integration of camera errors in the scanner opened with
  /// [launchPrescriptionScanner], with the error description.
  ///
  /// Note: Only supported on iOS.
  ///
  StreamController<String> get scannerCameraErrorListener;

  /// Called when the user photographs a paper prescription in the SDK scanner, with the encoded photo as [imageData].
  ///
  /// Return [IaModelPrescriptionScanDecision.handled] to take over the prescription,
  /// or [IaModelPrescriptionScanDecision.error] to reject it. When not set, or when it returns
  /// [IaModelPrescriptionScanDecision.performDefault], the SDK continues with its built-in handling.
  ///
  /// Usage:
  ///
  /// ```dart
  /// IaSdk.instance.prescription.onPrescriptionPhotoScanned = (imageData) async {
  ///   await uploadPrescription(imageData);
  ///   return IaModelPrescriptionScanDecision.handled;
  /// };
  /// ```
  ///
  Future<IaModelPrescriptionScanDecision> Function(Uint8List imageData)? onPrescriptionPhotoScanned;

  /// Called when the user scans an e-prescription (eRezept) QR code in the SDK scanner.
  ///
  /// Return [IaModelPrescriptionScanDecision.handled] to take over the prescription,
  /// or [IaModelPrescriptionScanDecision.error] to reject it. When not set, or when it returns
  /// [IaModelPrescriptionScanDecision.performDefault], the SDK continues with its built-in handling.
  ///
  Future<IaModelPrescriptionScanDecision> Function(IaModelPrescriptionEPrescriptionScan scan)? onEPrescriptionScanned;
}
