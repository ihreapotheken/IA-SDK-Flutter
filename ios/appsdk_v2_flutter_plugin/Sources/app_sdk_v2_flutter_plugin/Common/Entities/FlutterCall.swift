//
//  FlutterCall.swift
//  appsdk_v2_flutter_plugin
//
//  Created by Danijel Huis on 29.12.2025..
//

/**
 * Collection of available method invocation identifiers.
 */
enum FlutterCall: CaseIterable {
    /**
     * Allocates the SDK runtime resources.
     */
    case initIaSdk
    
    /**
     * Registers SDK modules for use in the application.
     */
    case register
    
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
     * String identifier getter definition.
     */
    var name: String {
        return String(describing: self)
    }
}
