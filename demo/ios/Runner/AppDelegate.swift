import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  var iaSdkBindings: IaClientBindings!
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let pluginRegistrar = self.registrar(forPlugin: "ia-sdk")
    iaSdkBindings = IaClientBindings(
      viewController: controller,
      pluginRegistrar: pluginRegistrar,
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
