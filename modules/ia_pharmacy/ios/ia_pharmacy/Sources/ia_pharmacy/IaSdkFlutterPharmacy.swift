import Flutter
import UIKit
import IACore
import IAPharmacy

@MainActor
public class IaSdkFlutterPharmacy: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
        name: "de.ihreapotheken/sdk/pharmacyDetails",
        binaryMessenger: registrar.messenger(),
    )
    let instance = IaSdkFlutterPharmacy()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "register":
        IASDK.register([IASDKModule.pharmacyDetails])
        result(nil)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
