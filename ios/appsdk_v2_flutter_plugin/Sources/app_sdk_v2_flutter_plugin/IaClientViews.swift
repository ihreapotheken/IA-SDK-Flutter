import Flutter
import IACore
import IAIntegrations
import IAOrdering
import IAOverTheCounter
import SwiftUI
import UIKit

/// Collection of views available for client display.
enum IaClientViews: CaseIterable {
  /**
   * Dashboard screen displaying main app content.
   */
  case startScreen

  /**
   * Product search and filtering screen.
   */
  // case productSearchScreen

  /**
   * String identifier getter definition.
   */
  var name: String {
    return String(describing: self)
  }

  /**
   * Visual interface representation.
   */
  func view(navigationController: UINavigationController? = nil) -> AnyView {
    switch self {
    case IaClientViews.startScreen:
      if navigationController == nil {
        return AnyView(IAIntegrations.IAStartScreen())
      } else {
        return AnyView(
          IAIntegrations.IAStartScreen().hostEmbedStyle(
            .navigation(
              onDismiss: {
                navigationController?.dismiss(animated: true)
                navigationController?.popViewController(animated: true)
              }
            )
          )
        )
      }
    // case IaClientViews.productSearchScreen:
    //   return AnyView(IAOverTheCounter.IAProductSearchScreen())
    }
  }
}

internal class IaClientViewUIKitViewController: UIViewController {
  let viewId: String!

  init(viewId: String!) {
    self.viewId = viewId
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    guard
      let swiftUIView = IaClientViews.allCases.first(where: { view in view.name == viewId })?.view(
        navigationController: self.navigationController
      )
    else {
      fatalError("View ID \(viewId!) not defined for display.")
    }
    let hostingController = UIHostingController(
      rootView: swiftUIView,
    )
    addChild(hostingController)
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    hostingController.didMove(toParent: self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }
}

private class IaClientNativeView: NSObject, FlutterPlatformView {
  private var viewController: UIViewController

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?,
    binaryMessenger messenger: FlutterBinaryMessenger?
  ) {
    viewController = IaClientViewUIKitViewController(viewId: (args as! String))
    super.init()
  }

  func view() -> UIView {
    return viewController.view
  }
}

internal class IaClientNativeViewFactory: NSObject, FlutterPlatformViewFactory {
  private var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return IaClientNativeView(
      frame: frame,
      viewIdentifier: viewId,
      arguments: args,
      binaryMessenger: messenger)
  }

  func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}
