part of '../impl.dart';

Future<Map<String, dynamic>> _prescriptionPhotoScannedHandler(dynamic args) async {
  final callback = IaModulePrescription._instance?.onPrescriptionPhotoScanned;
  if (callback == null) {
    return IaModelPrescriptionScanDecision.performDefault.toJson();
  }
  if (args is! Map) {
    throw Exception(
      'prescriptionPhotoScanned: Invalid arguments type.',
    );
  }
  final imageData = args['imageData'];
  if (imageData is! Uint8List) {
    throw Exception(
      'prescriptionPhotoScanned: Missing or incorrect type imageData: ${imageData.runtimeType}.',
    );
  }
  final decision = await callback(imageData);
  return decision.toJson();
}

Future<Map<String, dynamic>> _ePrescriptionScannedHandler(dynamic args) async {
  final callback = IaModulePrescription._instance?.onEPrescriptionScanned;
  if (callback == null) {
    return IaModelPrescriptionScanDecision.performDefault.toJson();
  }
  if (args is! Map) {
    throw Exception(
      'ePrescriptionScanned: Invalid arguments type.',
    );
  }
  final rawCode = args['rawCode'];
  if (rawCode is! String) {
    throw Exception(
      'ePrescriptionScanned: Missing or incorrect type rawCode: ${rawCode.runtimeType} $rawCode.',
    );
  }
  final urls = args['urls'];
  if (urls is! Iterable || urls.any((url) => url is! String)) {
    throw Exception(
      'ePrescriptionScanned: Missing or incorrect type urls: ${urls.runtimeType} $urls.',
    );
  }
  final decision = await callback(
    IaModelPrescriptionEPrescriptionScan(
      rawCode: rawCode,
      urls: List<String>.from(urls),
    ),
  );
  return decision.toJson();
}
