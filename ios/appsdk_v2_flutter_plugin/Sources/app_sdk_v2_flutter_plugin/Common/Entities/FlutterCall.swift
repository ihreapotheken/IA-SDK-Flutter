/**
 * Collection of available method invocation identifiers.
 */
enum FlutterCall: CaseIterable {
    /**
     * Registers SDK modules for use in the application.
     */
    case register

    /**
     * Allocates the SDK runtime resources.
     */
    case initialize
    
    /**
     * Selects a pharmacy by providing an identifier.
     */
    case setPharmacyId
    
    /**
     * Resets the state of user cart, clearing any added products or prescriptions.
     */
    case clearCart
    
    /**
     * Forwards the client personal information to the ia.de library for checkout purposes.
     */
    case setGuestUserData
    
    /**
     * Resets the user data and onboarding status (pharmacy selection, user consents statuses).
     */
    case logout
    
    /**
     * Places a new [UIViewController] object into the navigation stack.
     */
    case launchRoute
    
    /**
     * Forwards a collection of prescription objects with the ia.de checkout services.
     */
    case transferPrescriptions
    
    /**
     * Closes any overlaying ia.de screen contents.
     */
    case finishAllActivities

    /**
     * Transfers user data from SDK v1 to the current SDK.
     */
    case transferSDKv1UserData

    /**
     * Returns whether the SDK has been successfully initialized.
     */
    case isInitialized

    /**
     * Deletes the user account from the SDK backend.
     */
    case deleteUser

    /**
     * Returns the current server environment.
     */
    case getEnvironment

    /**
     * Clears cached SDK data for initialization and/or prerequisites.
     */
    case cleanCache

    /**
     * Returns the currently selected pharmacy identifier.
     */
    case getPharmacyId

    /**
     * Returns the current cart details.
     */
    case getCartDetails

    /**
     * Deletes the order history.
     */
    case deleteOrderHistory

    /**
     * Sets the user's billing address used to pre-fill checkout.
     */
    case setUserBillingAddress

    /**
     * Sets the user's delivery address used to pre-fill checkout.
     */
    case setUserDeliveryAddress

    /**
     * Legacy setup required when the host app is the Core app.
     */
    case legacySetupAsCoreApp

    /**
     * Toggles the Pharmi mascot illustrations on an already-initialized SDK.
     */
    case setShouldShowMascotIllustrations

    /**
     * String identifier getter definition.
     */
    var name: String {
        return String(describing: self)
    }
}
