import Flutter
import UIKit
import IACore
import IAOrdering

@MainActor
public class IaSdkFlutterOrdering: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
        name: "de.ihreapotheken/sdk/ordering",
        binaryMessenger: registrar.messenger(),
    )
    let instance = IaSdkFlutterOrdering()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "register":
        IASDK.register([IASDKModule.ordering])
        result(nil)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
