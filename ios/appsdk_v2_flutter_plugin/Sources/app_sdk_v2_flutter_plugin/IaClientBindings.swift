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

        // Component size updates are sent back over the main SDK channel
        // (routed by Dart via IaBaseCallbacks).
        let componentsViewFactory = IASDKComponentsViewFactory(componentsChannel: self.channel)
        for component in IASDKComponentIdentifier.allCases {
            registrar.register(
                componentsViewFactory,
                withId: component.rawValue
            )
        }
    }
}
