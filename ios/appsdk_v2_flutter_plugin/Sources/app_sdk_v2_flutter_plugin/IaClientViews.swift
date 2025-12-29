import Flutter
import IACore
import IAIntegrations
import IAOrdering
import IAOverTheCounter
import SwiftUI
import UIKit

enum IaClientViews: CaseIterable {
    /**
     * Start screen displaying main app content.
     */
    case startScreen

    /**
     * Cart screen displaying order overview.
     */
    case cartScreen
    
    /**
     * Product search screen.
     */
    case productSearchScreen

    init?(name: String) {
        guard let value = IaClientViews.allCases.first(where: { view in view.name == name }) else {
            return nil
        }
        self = value
    }

    /**
     * String identifier getter definition.
     */
    var name: String {
        return String(describing: self)
    }

    /**
     * Visual interface representation.
     */
    func iaScreen() -> any IAScreen {
        switch self {
        case IaClientViews.startScreen:
            IAStartScreen()

        case IaClientViews.cartScreen:
            IACartScreen()
            
        case IaClientViews.productSearchScreen:
            IAProductSearchScreen()
        }
    }
}

private class IaClientNativeView: NSObject, FlutterPlatformView {
    private var viewController: UIViewController?
    private var args: Any?

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        self.args = args
        self.viewController = IaClientViews(name: args as! String)?.iaScreen()
            .viewControllerForPresenting(onDismiss: nil)
        super.init()
    }

    func view() -> UIView {
        guard let view = viewController?.view else {
            assertionFailure(
                "IaClientNativeView: Failed to find view for args: \(String(describing: args))")
            return UIView()
        }

        return view
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
