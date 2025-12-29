import 'package:appsdk_v2_flutter_plugin/features/ia_sdk/ia_sdk_platform_view_launcher.dart';

/// Prescription module for the IA SDK.
///
/// Provides functionality related to prescription scanning.
/// This mirrors the IAPrescription module from the native SDKs.
///
class IaPrescription {
  /// Creates an instance of [IaPrescription].
  ///
  const IaPrescription();

  /// Launches the prescription scanner screen experience on top of the navigation stack.
  ///
  Future<void> launchPrescriptionScanner() async {
    await IaSdkPlatformViewLauncher.launchPrescriptionScanner();
  }

  /// Launches the E-Prescription scanner screen experience on top of the navigation stack.
  ///
  Future<void> launchEPrescriptionScanner() async {
    await IaSdkPlatformViewLauncher.launchEPrescriptionScanner();
  }
}
