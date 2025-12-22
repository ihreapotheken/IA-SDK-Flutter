//
//  Error+.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 22.12.2025..
//

import Flutter

/// Extension to convert Swift errors to FlutterError.
extension Error {
    /// Converts this error to a FlutterError with appropriate code and message.
    var flutterError: FlutterError {
        if let argumentError = self as? IaArgumentError {
            return FlutterError(
                code: "ARG_ERROR",
                message: argumentError.localizedDescription,
                details: nil
            )
        } else {
            let errorType = String(describing: type(of: self))
            return FlutterError(
                code: errorType,
                message: self.localizedDescription,
                details: nil
            )
        }
    }
}
