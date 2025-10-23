import Flutter

@MainActor
class IaClientBindings {
  private var channel: FlutterMethodChannel!
  
  init?(
    viewController: FlutterViewController,
    pluginRegistrar: FlutterPluginRegistrar?,
  ) {
    self.channel = FlutterMethodChannel(
      name: "de.ihreapotheken/sdk",
      binaryMessenger: viewController.binaryMessenger)
    let methodHandler = IaClientMethods(bindings: self)
    self.channel.setMethodCallHandler(methodHandler.callHandler)
    guard let registrar = pluginRegistrar else { return nil }
    let factory = IaClientNativeViewFactory(messenger: registrar.messenger())
    for view in IaClientViews.allCases {
      registrar.register(
        factory,
        withId: view.name)
    }
  }
}
