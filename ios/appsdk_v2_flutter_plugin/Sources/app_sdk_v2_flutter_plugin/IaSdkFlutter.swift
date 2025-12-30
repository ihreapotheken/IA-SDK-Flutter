import Flutter
import UIKit
import Foundation

@MainActor
public class IaSdkFlutter: NSObject, FlutterPlugin {
  static var iaSdkBindings: IaClientBindings!
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = IaSdkFlutter()
    let rootViewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    if let flutterViewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
      Self.iaSdkBindings = IaClientBindings(
        viewController: flutterViewController,
        pluginRegistrar: registrar,
      )
    }
  }
}
