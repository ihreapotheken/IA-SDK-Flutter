//
//  IaLaunchRouteArguments.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 29.12.2025..
//

import Foundation

/// Arguments for launching a route.
struct IaLaunchRouteArguments: Decodable {
    /// The view identifier as a string (e.g., "startScreen", "productSearchScreen").
    let viewId: String

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
