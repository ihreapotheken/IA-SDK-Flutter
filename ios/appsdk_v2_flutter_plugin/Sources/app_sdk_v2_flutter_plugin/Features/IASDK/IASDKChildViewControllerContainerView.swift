import UIKit

/// Flutter only adds the platform view, so a view controller behind it is outside the view controller hierarchy and
/// UIKit doesn't pass it safe area insets, appearance callbacks or trait changes. This container hosts the view
/// controller's view and, while in a window, adds the view controller as a child of the nearest view controller
/// (Flutter's).
@MainActor
final class IASDKChildViewControllerContainerView: UIView {
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
