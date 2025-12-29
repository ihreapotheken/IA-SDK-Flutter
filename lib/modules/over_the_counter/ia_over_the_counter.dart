import 'package:appsdk_v2_flutter_plugin/modules/ia_sdk/ia_sdk_platform_view_launcher.dart';

/// Over the counter module for the IA SDK.
///
/// Provides functionality related to product search and purchasing.
/// This mirrors the IAOverTheCounter module from the native SDKs.
///
class IaOverTheCounter {
  /// Creates an instance of [IaOverTheCounter].
  ///
  const IaOverTheCounter();

  /// Launches the product search screen experience on top of the navigation stack.
  ///
  Future<void> launchProductSearchRoute() async {
    await IaSdkPlatformViewLauncher.launchProductSearchRoute();
  }
}
