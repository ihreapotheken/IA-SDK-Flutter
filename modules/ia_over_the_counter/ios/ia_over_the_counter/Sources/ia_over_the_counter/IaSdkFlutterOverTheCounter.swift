import Flutter
import UIKit
import IACore
import IAOverTheCounter

@MainActor
public class IaSdkFlutterOverTheCounter: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
        name: "de.ihreapotheken/sdk/overTheCounter",
        binaryMessenger: registrar.messenger(),
    )
    let instance = IaSdkFlutterOverTheCounter()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "register":
        IASDK.register([IASDKModule.overTheCounter])
        result(nil)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
