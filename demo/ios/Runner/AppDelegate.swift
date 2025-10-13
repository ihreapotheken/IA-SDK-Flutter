import Flutter
import UIKit
import IACore
import IAIntegrations
import IAOverTheCounter
import IAOrdering

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// ia.de SDK specifications.
  ///
  let iaSdkKey = "e9f3d6a12c4b8f75d1e0a93c5b7d6e2f3c1a9b8e7f4d2c0a1b6e5d3f8c7a1b9e"
  let iaSdkClientId = "test.demo.sdkv2.ios"
  let iaSdkDelegate = IaSdkDelegate()
  
  /// Allocate ia.de SDK resources.
  ///
  func initIaSdk(result: @escaping FlutterResult) async {
    IASDK.configuration.apiKey = iaSdkKey
    IASDK.configuration.clientID = iaSdkClientId
    IASDK.setEnvironment(.staging)
    IASDK.delegate = iaSdkDelegate
    IAIntegrationsSDK.register()
    IAOverTheCounterSDK.register()
    IAOrderingSDK.register(delegate: iaSdkDelegate)
    do {
        let _ = try await IASDK.initialize(options: .init(
          prerequisitesOptions: IASDKPrerequisitesOptions(
            shouldShowIndicator: true,
            isCancellable: true,
            isAnimated: true)
          ),
        )
        result(true)
    } catch {
      result(FlutterError(code: "INIT_FAILED", message: error.localizedDescription, details: nil))
    }
  }
  
  /// Allocate Flutter host communication channel.
  ///
  func initFlutterMethodChannel() {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let communicationChannel = FlutterMethodChannel(
      name: "de.ihreapotheken/sdk",
      binaryMessenger: controller.binaryMessenger)
    communicationChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "initIaSdk":
        Task.init {
          await self?.initIaSdk(result: result)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    })
  }
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    initFlutterMethodChannel()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class IaSdkDelegate : SDKDelegate, OrderingDelegate {
  func pharmacyHeaderWillOpenPharmacyScreen(pharmacy: IACore.Pharmacy) -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func startScreenWillOpenProductSearchScreen() -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func startScreenWillOpenDiscoverOffersScreen() -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func hostAppShouldOpenPrivacyPolicy() {
  }
  
  func willOpenApofinder() -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func apofinderDidChangePharmacy(_ pharmacy: IACore.Pharmacy, isFromPrerequisites: Bool) {
  }
  
  func orderingWillOpenProductSearchScreen() -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func orderingWillOpenPharmacyScreen(pharmacy: IACore.Pharmacy) -> IACore.WillOpenResult {
    return .notHandled
  }
  
  func cartButtonWillOpenCartScreen() -> IACore.WillOpenResult {
    return .notHandled
  }
}
