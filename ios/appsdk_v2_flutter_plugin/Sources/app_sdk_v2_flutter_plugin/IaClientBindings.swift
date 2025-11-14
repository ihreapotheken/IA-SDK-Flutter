import Flutter
import IACore
import IAOrdering
import IAIntegrations
import IAPharmacy
import IAOrdering
import IAPrescription
import IAOverTheCounter
import IACardLink

@MainActor
class IaClientBindings {
  var channel: FlutterMethodChannel!
  
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

class IaClientDelegate : SDKDelegate, OrderingDelegate, PrescriptionDelegate, CardLinkDelegate {
  let channel: FlutterMethodChannel
  
  init(
    channel: FlutterMethodChannel,
  ) {
    self.channel = channel
  }
  
  func orderingWillShowThankYouScreen(orders: [IAOrder], dismissable: (any Dismissable)?) -> HandlingDecision {
    if let order = orders.first {
      channel.invokeMethod(
        "didFinishOrder",
        arguments: [
          "hostOrderId": order.orderCode,
          "sdkOrderId": order.clientOrderID,
        ],
      )
    }
    return .performDefault
  }
}
