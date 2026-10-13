import Foundation

/// Arguments for launching a route.
struct IaLaunchRouteArguments: Decodable {
    /// The view identifier as a string (e.g., "startScreen", "searchScreen").
    let viewId: String

    /// Whether Apofinder can be closed without selecting a pharmacy.
    let isCancellable: Bool?

    /// Whether the product search field is focused when the screen opens.
    let focusesOnAppear: Bool?

    /// Converts the viewId string to an IASDKViewIdentifier enum case.
    var view: IASDKViewIdentifier {
        get throws {
            guard let view = IASDKViewIdentifier(rawValue: viewId) else {
                throw IaArgumentError.decodingArgumentFailed(description: "Unknown view: \(viewId)")
            }
            return view
        }
    }
}
