import Flutter
import UIKit
import IACore
import IACardLink

@MainActor
public class IaSdkFlutterCardLink: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
        name: "de.ihreapotheken/sdk/cardLink",
        binaryMessenger: registrar.messenger(),
    )
    let instance = IaSdkFlutterCardLink()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "register":
        IASDK.register([IASDKModule.cardLink])
        result(nil)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
