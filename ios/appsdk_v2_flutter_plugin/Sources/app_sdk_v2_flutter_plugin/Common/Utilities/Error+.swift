import Flutter

/// Extension to convert Swift errors to FlutterError.
extension Error {
    /// Converts this error to a FlutterError with appropriate code and message.
    func flutterError(methodName: String) -> FlutterError {
        if let argumentError = self as? IaArgumentError {
            return FlutterError(
                code: "ARG_ERROR",
                message: argumentError.localizedDescription,
                details: nil
            )
        } else {
            // Try to find matching FlutterCall for specific error code
            let errorCode: String
            if let flutterCall = FlutterCall.allCases.first(where: { $0.name == methodName }) {
                errorCode = codeFromFlutterCall(flutterCall)
            } else {
                errorCode = "METHOD_ERROR"
            }

            return FlutterError(
                code: errorCode,
                message: self.localizedDescription,
                details: nil
            )
        }
    }

    private func codeFromFlutterCall(_ flutterCall: FlutterCall) -> String {
        switch flutterCall {
        case .initialize: "INIT_ERROR"
        case .register: "REGISTER_ERROR"
        case .setPharmacyId: "SET_PHARMACY_ERROR"
        case .clearCart: "CLEAR_CART_ERROR"
        case .setGuestUserData: "SET_GUEST_USER_DATA_ERROR"
        case .logout: "LOGOUT_ERROR"
        case .launchRoute: "LAUNCH_ROUTE_ERROR"
        case .transferPrescriptions: "PRESCRIPTION_TRANSFER_ERROR"
        case .finishAllActivities: "FINISH_ALL_ACTIVITIES_ERROR"
        }
    }
}
