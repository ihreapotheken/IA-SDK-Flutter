import Combine
import Flutter
import IACore
import IAIntegrations

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
        let plugin = IASDKPlugin(bindings: self)
        self.channel.setMethodCallHandler(plugin.callHandler)
        guard let registrar = pluginRegistrar else { return nil }
        let viewFactory = IASDKViewFactory(messenger: registrar.messenger())
        for view in IASDKViewIdentifier.allCases {
            registrar.register(
                viewFactory,
                withId: view.rawValue
            )
        }
    }
}
