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

class IaClientDelegate: SDKDelegate {
  let channel: FlutterMethodChannel
  
  let cartItemCountListener: CurrentValueSubject<Int, Never>

  init(
    channel: FlutterMethodChannel,
    cartItemCountListener: CurrentValueSubject<Int, Never>
  ) {
    self.channel = channel
    self.cartItemCountListener = cartItemCountListener
  }
  
  // @TODO delegate
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
    
  // @TODO delegate
  func orderingDidUpdateCart(cartState: IACartState) {
    if let cartItemCount = cartState.cartDetails?.totalAmountInCart {
      cartItemCountListener.value = cartItemCount
    }
  }
}
