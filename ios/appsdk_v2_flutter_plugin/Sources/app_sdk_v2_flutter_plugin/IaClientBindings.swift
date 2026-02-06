import Combine
import Flutter
import IACore
import IAIntegrations

@MainActor
class IaClientBindings {
    var channel: FlutterMethodChannel
    init(registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        self.channel = FlutterMethodChannel(
            name: "de.ihreapotheken/sdk",
            binaryMessenger: messenger
        )
        let plugin = IASDKPlugin(bindings: self)
        self.channel.setMethodCallHandler(plugin.callHandler)
        let viewFactory = IASDKViewFactory(messenger: messenger)
        for view in IASDKViewIdentifier.allCases {
            registrar.register(
                viewFactory,
                withId: view.rawValue
            )
        }
    }
}
