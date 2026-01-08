import 'package:appsdk_v2_flutter_plugin/src/features/ia_sdk/ia_sdk_platform_view_launcher.dart';

/// Pharmacy module for the IA SDK.
///
/// Provides functionality related to pharmacy details.
/// This mirrors the IAPharmacy module from the native SDKs.
///
class IaPharmacy {
  /// Creates an instance of [IaPharmacy].
  ///
  const IaPharmacy();

  /// Launches the pharmacy details screen experience on top of the navigation stack.
  ///
  Future<void> launchPharmacyDetails() async {
    await IaSdkPlatformViewLauncher.launchPharmacyDetails();
  }
}
