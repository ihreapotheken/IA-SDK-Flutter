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

  func sdkShouldOverrideRoute(_ routeOverride: IARouteOverride, decisionHandler: @escaping (HandlingDecision) -> Void) {
    // Convert route override to string
    let routeOverrideString: String
    switch routeOverride {
    case .cart:
      routeOverrideString = "cart"
    case .pharmacyDetails:
      routeOverrideString = "pharmacyDetails"
    case .thankYou:
      routeOverrideString = "thankYou"
    case .imprint:
      routeOverrideString = "imprint"
    case .hostAppPrivacyPolicy:
      routeOverrideString = "hostAppPrivacyPolicy"
    case .apofinder:
      routeOverrideString = "apofinder"
    }

    // Call Flutter callback and wait for response
    channel.invokeMethod(
      "shouldOverrideRoute",
      arguments: ["routeOverride": routeOverrideString]
    ) { result in
      print(">>> Got result: \(result)")
        
      // Parse the response
      guard let decisionString = result as? String else {
        // If no valid response, perform default
        decisionHandler(.performDefault)
        return
      }

      // Convert string to HandlingDecision
      let decision: HandlingDecision
      switch decisionString {
      case "handled":
        decision = .handled
      case "performDefault":
        decision = .performDefault
      default:
        decision = .performDefault
      }

      decisionHandler(decision)
    }
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
