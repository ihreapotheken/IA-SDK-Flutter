import Flutter
import UIKit
import Foundation

@MainActor
public class IaSdkFlutter: NSObject, FlutterPlugin {
  static var iaSdkBindings: IaClientBindings!

  public static func register(with registrar: FlutterPluginRegistrar) {
    Self.iaSdkBindings = IaClientBindings(registrar: registrar)
  }
}
