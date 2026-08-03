import Foundation
import IACore
import Flutter
import UIKit

@MainActor
final class IASDKViewFactory: NSObject, FlutterPlatformViewFactory {
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

        let view = viewIdentifier.iaScreen().viewControllerForPresenting(onDismiss: nil).view ?? UIView()
        return IASDKFlutterPlatformView(uiView: view)
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Support -

private final class IASDKFlutterPlatformView: NSObject, FlutterPlatformView {
    private let uiView: UIView
    
    init (uiView: UIView) {
        self.uiView = uiView
    }
    
    func view() -> UIView {
        uiView
    }
    
    static var empty: IASDKFlutterPlatformView {
        IASDKFlutterPlatformView(uiView: UIView())
    }
}
