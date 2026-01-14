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
        guard let viewId = args as? String else {
            assertionFailure("IASDKViewManager: Failed to convert args (viewId) to string.")
            return IASDKFlutterPlatformView.empty
        }
        guard let viewId = IASDKViewIdentifier(rawValue: viewId) else {
            assertionFailure("IASDKViewManager: Failed to find view for args: \(String(describing: args))")
            return IASDKFlutterPlatformView.empty
        }
        
        let view = viewId.iaScreen().viewControllerForPresenting(onDismiss: nil).view ?? UIView()
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
