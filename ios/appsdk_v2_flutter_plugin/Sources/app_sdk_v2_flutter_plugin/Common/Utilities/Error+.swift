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
        case .transferSDKv1UserData: "TRANSFER_SDK_V1_USER_DATA_ERROR"
        case .isInitialized: "IS_INITIALIZED_ERROR"
        case .deleteUser: "DELETE_USER_ERROR"
        case .getEnvironment: "GET_ENVIRONMENT_ERROR"
        case .cleanCache: "CLEAN_CACHE_ERROR"
        case .getPharmacyId: "GET_PHARMACY_ID_ERROR"
        case .getCartDetails: "GET_CART_DETAILS_ERROR"
        case .deleteOrderHistory: "DELETE_ORDER_HISTORY_ERROR"
        case .setUserBillingAddress: "SET_USER_BILLING_ADDRESS_ERROR"
        case .setUserDeliveryAddress: "SET_USER_DELIVERY_ADDRESS_ERROR"
        }
    }
}
