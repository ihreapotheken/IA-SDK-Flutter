import Foundation
import Flutter
import IACore
import SwiftUI
import UIKit

/// Native identifiers for the inline component platform views Flutter can
/// embed via per-component widget classes (e.g. `IaCartButton`,
/// `IaProductGrid`).
enum IASDKComponentIdentifier: String, CaseIterable {
    case cartButton
    case productGrid
}

@MainActor
final class IASDKComponentsViewFactory: NSObject, FlutterPlatformViewFactory {
    private let componentsChannel: FlutterMethodChannel

    init(componentsChannel: FlutterMethodChannel) {
        self.componentsChannel = componentsChannel
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let params = (args as? [String: Any]) ?? [:]
        let identifier = (params["viewId"] as? String).flatMap(IASDKComponentIdentifier.init(rawValue:))

        switch identifier {
        case .cartButton:
            return IASDKComponentPlatformView(rootView: AnyView(IACartButton())) { rootView in
                SizeReportingHostingController(viewId: viewId, channel: self.componentsChannel, rootView: rootView)
            }

        case .productGrid:
            let gridView = IAProductGrid(
                type: Self.gridType(from: params),
                shouldShowLoading: params["shouldShowLoading"] as? Bool ?? true,
            )
            return IASDKComponentPlatformView(rootView: AnyView(gridView)) { rootView in
                SizeReportingHostingController(viewId: viewId, channel: self.componentsChannel, rootView: rootView)
            }

        case .none:
            assertionFailure("IASDKComponentsViewFactory: Unknown component viewId in args: \(String(describing: args))")
            return IASDKComponentPlatformView.empty
        }
    }

    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    private static func gridType(from params: [String: Any]) -> IAProductGridType {
        let pzn = params["pzn"] as? String
        switch params["type"] as? String {
        case "productsOfTheMonth":
            return .productsOfTheMonth(pznToExclude: pzn)
        case "productRecommendations":
            return .productRecommendations(pzn: pzn ?? "")
        case "customersAlsoBought":
            return .customersAlsoBought(pzn: pzn ?? "")
        default:
            return .currentOffers(pznToExclude: pzn)
        }
    }
}

// MARK: - Support -

@MainActor
private final class IASDKComponentPlatformView: NSObject, FlutterPlatformView {
    private let hostingController: UIViewController

    init(
        rootView: AnyView,
        controllerBuilder: (AnyView) -> UIHostingController<AnyView>,
    ) {
        self.hostingController = controllerBuilder(rootView)
        super.init()
    }

    private init(empty: Void) {
        self.hostingController = UIViewController()
        super.init()
    }

    func view() -> UIView {
        return hostingController.view
    }

    static var empty: IASDKComponentPlatformView {
        IASDKComponentPlatformView(empty: ())
    }
}

/// A [UIHostingController] subclass that reports its SwiftUI content's
/// preferred "fill width, wrap content height" size to Flutter via the shared
/// components MethodChannel each time SwiftUI re-lays out (including
/// state-driven re-renders). Sizes are reported in points (logical pixels).
@MainActor
final class SizeReportingHostingController<Content: View>: UIHostingController<Content> {
    private let viewId: Int64
    private let channel: FlutterMethodChannel
    private var lastReported: CGSize = .zero

    init(viewId: Int64, channel: FlutterMethodChannel, rootView: Content) {
        self.viewId = viewId
        self.channel = channel
        super.init(rootView: rootView)
        view.backgroundColor = .clear
        if #available(iOS 16.0, *) {
            sizingOptions = [.intrinsicContentSize]
        }
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async { [weak self] in
            self?.measureAndReport()
        }
    }

    private func measureAndReport() {
        guard isViewLoaded else { return }
        let width = view.bounds.width
        guard width > 0 else { return }
        let target = CGSize(width: width, height: .greatestFiniteMagnitude)
        let size = sizeThatFits(in: target)
        guard size.width > 0, size.height > 0 else { return }
        guard size != lastReported else { return }
        lastReported = size

        channel.invokeMethod(
            "updateComponentSize",
            arguments: [
                "viewId": viewId,
                "width": Double(size.width),
                "height": Double(size.height),
            ],
        )
    }
}
