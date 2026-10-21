part of '../impl.dart';

Future<void> _scannerCameraErrorHandler(dynamic args) async {
  final message = args is Map ? args['message'] : null;
  if (message is! String) {
    throw Exception(
      'prescriptionScannerCameraError: Missing or incorrect type message: ${message.runtimeType} $message.',
    );
  }
  IaModulePrescription._scannerCameraErrorListener.add(message);
}
