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
   * Cart screen displaying order overview.
   */
  case cartScreen

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
    case IaClientViews.cartScreen:
      if navigationController == nil {
        return AnyView(IAOrdering.IACartScreen())
      } else {
        return AnyView(
          IAOrdering.IACartScreen().hostEmbedStyle(
            .navigation(
              onDismiss: {
                navigationController?.dismiss(animated: true)
                navigationController?.popViewController(animated: true)
              }
            )
          )
        )
      }
    }
  }
  
  static public let navController = UINavigationController()
  
  public func start(
    viewId: String? = nil,
  ) {
    let baseViewController: UIViewController? = UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .first?.rootViewController
    func getTopViewController(base: UIViewController? = baseViewController) -> UIViewController? {
      if let nav = base as? UINavigationController {
        return getTopViewController(base: nav.visibleViewController)
      }
      if let tab = base as? UITabBarController,
        let selected = tab.selectedViewController
      {
        return getTopViewController(base: selected)
      }
      if let presented = base?.presentedViewController {
        return getTopViewController(base: presented)
      }
      return base
    }
    guard
      let topViewController = getTopViewController()
    else {
      fatalError("No UIViewController object found.")
    }
    let viewController = IaClientViewUIKitViewController(
      viewId: viewId ?? name,
    )
    Self.navController.addChild(viewController)
    Self.navController.modalPresentationStyle = .fullScreen
    topViewController.present(Self.navController, animated: true)
  }
}

public class IaClientViewUIKitViewController: UIViewController {
  static private var controllers: [IaClientViewUIKitViewController] = []

  let viewId: String!

  init(
    viewId: String!,
  ) {
    self.viewId = viewId
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
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
    if !Self.controllers.contains(self) {
      Self.controllers.append(self)
    }
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
    if isMovingFromParent || isBeingDismissed {
      Self.controllers.removeAll(where: { it in it == self })
    }
  }

  public static func finishAllActivities() {
    IaClientViews.navController.popToRootViewController(animated: false)
    IaClientViews.navController.popViewController(animated: false)
    IaClientViews.navController.dismiss(animated: false)
    for controller in controllers {
      controller.navigationController?.popToRootViewController(animated: false)
      controller.navigationController?.popViewController(animated: false)
      controller.navigationController?.dismiss(animated: false)
    }
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
