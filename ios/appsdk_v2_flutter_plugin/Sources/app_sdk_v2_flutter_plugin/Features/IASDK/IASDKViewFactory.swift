import Foundation
import IACore
import Flutter
import SwiftUI
import UIKit

@MainActor
final class IASDKViewFactory: NSObject, FlutterPlatformViewFactory {
    /// Main SDK channel, used to report the SDK's back or close button to Dart (routed via IaBaseCallbacks).
    private let channel: FlutterMethodChannel
    /// Reports the pharmacy selected in an embedded Apofinder, as for a launched one.
    private let delegate: IaClientDelegate

    init(channel: FlutterMethodChannel, delegate: IaClientDelegate) {
        self.channel = channel
        self.delegate = delegate
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
        let channel = channel
        let delegate = delegate
        let onDismiss: EmptyCallback = {
            channel.invokeMethod("screenDismissed", arguments: ["viewId": platformViewId])
        }
        let params = args as? [String: Any]
        // Apofinder leaves closing to its caller, so a selection is reported as a dismiss too. Closing it without a
        // selection already goes through the SDK's close button, so `nil` isn't reported again. Only the SDK's own
        // Apofinder flow tells the SDK delegate, so the selection is reported here, like for a launched Apofinder.
        var screen = viewIdentifier.iaScreen(
            isCancellable: params?["isCancellable"] as? Bool ?? true,
            focusesOnAppear: params?["focusesOnAppear"] as? Bool,
            onApofinderFinish: { [weak delegate] pharmacy in
                guard let pharmacy else { return }
                delegate?.apofinderDidChangePharmacy(pharmacy, isFromPrerequisites: false)
                onDismiss()
            }
        )
        switch params?["embedStyle"] as? String {
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
