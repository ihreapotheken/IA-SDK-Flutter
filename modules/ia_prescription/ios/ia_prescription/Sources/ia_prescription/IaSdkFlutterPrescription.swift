import Flutter
import UIKit
import IACore
import IAPrescription

@MainActor
public class IaSdkFlutterPrescription: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
        name: "de.ihreapotheken/sdk/prescription",
        binaryMessenger: registrar.messenger(),
    )
    let instance = IaSdkFlutterPrescription()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "register":
        IASDK.register([IASDKModule.prescription])
        result(nil)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
