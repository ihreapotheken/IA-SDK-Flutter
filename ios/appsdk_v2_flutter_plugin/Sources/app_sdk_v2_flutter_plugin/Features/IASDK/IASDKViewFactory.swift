import Foundation
import IACore
import Flutter
import SwiftUI
import UIKit

@MainActor
final class IASDKViewFactory: NSObject, FlutterPlatformViewFactory {
    /// Main SDK channel, used to report the SDK's back or close button to Dart (routed via IaBaseCallbacks).
    private let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier platformViewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        // Dart's `IaSdkPlatformView` sends creation params as a map; earlier
        // callers passed the view ID as a bare string. Accept both.
        let viewId: String?
        switch args {
        case let params as [String: Any]: viewId = params["viewId"] as? String
        case let rawViewId as String: viewId = rawViewId
        default: viewId = nil
        }

        guard let viewId else {
            assertionFailure("IASDKViewManager: Failed to resolve viewId from args: \(String(describing: args))")
            return IASDKFlutterPlatformView.empty
        }
        guard let viewIdentifier = IASDKViewIdentifier(rawValue: viewId) else {
            assertionFailure("IASDKViewManager: Failed to find view for args: \(String(describing: args))")
            return IASDKFlutterPlatformView.empty
        }

        // The SDK shows a back or close button for the embed style the host chose, and reports its tap so Dart can
        // close the route. Without an embed style it shows neither.
        var screen = viewIdentifier.iaScreen()
        let channel = channel
        let onDismiss: EmptyCallback = {
            channel.invokeMethod("screenDismissed", arguments: ["viewId": platformViewId])
        }
        switch (args as? [String: Any])?["embedStyle"] as? String {
        case "navigation": screen.hostEmbedStyle = .navigation(onDismiss: onDismiss)
        case "presentation": screen.hostEmbedStyle = .presentation(onDismiss: onDismiss)
        default: break
        }
        // Hosting the screen as a SwiftUI view lets SwiftUI own its navigation controller.
        let hostingController = UIHostingController(rootView: AnyView(screen))
        hostingController.view.frame = frame
        return IASDKFlutterPlatformView(viewController: hostingController)
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Support -

/// Keeps the screen's view controller alive for as long as Flutter shows the platform view. Flutter only holds the
/// returned view, so without this the controller, and the navigation controller SwiftUI creates in it, deallocate.
@MainActor
private final class IASDKFlutterPlatformView: NSObject, FlutterPlatformView {
    private let viewController: UIViewController
    private let containerView: IASDKChildViewControllerContainerView

    init(viewController: UIViewController) {
        self.viewController = viewController
        self.containerView = IASDKChildViewControllerContainerView(viewController: viewController)
    }

    func view() -> UIView {
        containerView
    }

    static var empty: IASDKFlutterPlatformView {
        IASDKFlutterPlatformView(viewController: UIViewController())
    }
}

/// Flutter only adds the platform view, so a view controller behind it is outside the view controller hierarchy and
/// UIKit doesn't pass it safe area insets, appearance callbacks or trait changes. This container hosts the view
/// controller's view and, while in a window, adds the view controller as a child of the nearest view controller
/// (Flutter's).
@MainActor
private final class IASDKChildViewControllerContainerView: UIView {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(frame: viewController.view.frame)
        viewController.view.frame = bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(viewController.view)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            guard viewController.parent == nil, let parent = superview?.nearestViewController else { return }
            parent.addChild(viewController)
            viewController.didMove(toParent: parent)
        } else if viewController.parent != nil {
            viewController.willMove(toParent: nil)
            viewController.removeFromParent()
        }
    }
}

private extension UIResponder {
    /// This responder if it's a view controller, otherwise the first view controller up the responder chain.
    var nearestViewController: UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let viewController = current as? UIViewController { return viewController }
            responder = current.next
        }
        return nil
    }
}
