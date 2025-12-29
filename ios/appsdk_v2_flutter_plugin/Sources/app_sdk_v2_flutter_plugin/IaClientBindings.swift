import Combine
import Flutter
import IACardLink
import IACore
import IAIntegrations
import IAOrdering
import IAOverTheCounter
import IAPharmacy
import IAPrescription

@MainActor
class IaClientBindings {
    var channel: FlutterMethodChannel
    
    init?(
        viewController: FlutterViewController,
        pluginRegistrar: FlutterPluginRegistrar?,
    ) {
        self.channel = FlutterMethodChannel(
            name: "de.ihreapotheken/sdk",
            binaryMessenger: viewController.binaryMessenger
        )
        let plugin = IaSdkPlugin(bindings: self)
        self.channel.setMethodCallHandler(plugin.callHandler)
        guard let registrar = pluginRegistrar else { return nil }
        let factory = IaClientNativeViewFactory(messenger: registrar.messenger())
        for view in IaClientViews.allCases {
            registrar.register(
                factory,
                withId: view.name)
        }
    }
}
