# Public API Overview

This document provides a short overview of everything available to the host app. For details, see the
[API reference](https://ihreapotheken.github.io/docs/appsdk/flutter).

Functions marked iOS only or Android only throw a `MissingPluginException` on the other platform. Callbacks and
streams marked this way are never called on the other platform.

## appsdk_v2_flutter_plugin (core)

### Setup and initialization
- `IaSdk.instance.register(modules:)` - Registers the module packages you use
- `IaSdk.instance.initialize(config:)` - Initializes the SDK, see [Initialization](initialization.md)
- `IaSdkConfiguration` - Configuration passed to `initialize` (accessKey, clientId, etc.)
- `IaSdk.instance.getInitializationState()` - Returns the current initialization state
- `IaSdk.instance.isInitialized()` - Returns whether the SDK is initialized
- `IaSdk.instance.initializationStateListener` - Stream of initialization state changes
- `IaSdk.instance.getEnvironment()` - Returns the current server environment
- `IaSdk.instance.cleanCache(initialization:prerequisites:)` - Clears cached initialization and prerequisites data (iOS only)

### Module accessors
- `IaSdk.instance.overTheCounter` - Product search module, from `ia_over_the_counter`
- `IaSdk.instance.ordering` - Cart and checkout module, from `ia_ordering`
- `IaSdk.instance.pharmacy` - Pharmacy module, from `ia_pharmacy`
- `IaSdk.instance.prescription` - Prescription module, from `ia_prescription`
- `IaSdk.instance.cardLink` - CardLink module, from `ia_cardlink`

### Prerequisites
- `IaSdk.instance.launchPrerequisiteFlow()` - Runs the prerequisites explicitly (optional)
- `IaSdk.instance.isPrerequisiteFlowCompleted()` - Returns whether the prerequisites are completed (Android only)
- `IaSdk.instance.resetPrerequisites()` - Resets the prerequisites, including the selected pharmacy
- `IaSdk.instance.resetLegalDisclaimer()` - Resets the accepted legal documents (iOS only)
- `IaSdk.instance.setIsOnboardingShown(isOnboardingShown:)` - Sets whether onboarding was shown (iOS only)

### Screens
- `IaSdk.instance.launchStartRoute()` - Shows the [Start Screen](screens/start_screen.md)
- `IaSdk.instance.launchApofinder(isCancellable:)` - Shows the [Apofinder Screen](screens/apofinder_screen.md)
- `IaSdk.instance.finishAllActivities()` - Closes all SDK screens
- `IaSdkPlatformView(viewId:)` - Shows an SDK screen inside your own UI, see [Presentation](presentation.md)

### User data
- `IaSdk.instance.setGuestUserData(...)` - Sets the user's personal data, used in checkout
- `IaSdk.instance.setUserBillingAddress(...)` - Sets the billing address, used in checkout
- `IaSdk.instance.setUserDeliveryAddress(...)` - Sets the delivery address, used in checkout
- `IaSdk.instance.clearUserBillingAddress()` - Removes the billing address
- `IaSdk.instance.clearUserDeliveryAddress()` - Removes the delivery address
- `IaSdk.instance.logout()` - Resets the user data and the prerequisites
- `IaSdk.instance.deleteUser()` - Deletes the user data stored on the device (iOS only)
- `IaSdk.instance.getUserId()` - Returns the SDK's identifier for the current user (iOS only)

### Settings
- `IaSdk.instance.setShouldShowMascotIllustrations(shouldShowMascotIllustrations:)` - Shows or hides the mascot illustrations (iOS only)
- `IaSdk.instance.setAnalyticsConsent(consent:)` - Sets the user's analytics consent (Android only)
- `IaSdk.instance.setHapticFeedbackEnabled(isEnabled:)` - Turns haptic feedback on or off (Android only)

### Callbacks and streams
See [SDK Interaction](interaction.md).
- `IaSdk.instance.onSdkWillNavigateToTarget` - Lets your app handle SDK navigation, e.g. to the cart
- `IaSdk.instance.onApofinderDidChangePharmacy` - Called when the user selects a pharmacy in Apofinder
- `IaSdk.instance.onSdkBackAction` - Decides whether an SDK screen may close on back (Android only)
- `IaSdk.instance.analyticsEventListener` - Stream of analytics events (Android only)

### Debugging
- `IaSdk.instance.presentLogs()` - Shows the SDK's log viewer
- `IaSdk.instance.exportLogs()` - Writes the SDK's logs to a file and returns its path (Android only)
- `IaSdk.instance.logMessageListener` - Stream of SDK log messages (iOS only)
- `IaSdk.instance.removeAllCachedResponses()` - Removes the cached images (iOS only)

## ia_over_the_counter

- `IaModuleOverTheCounter()` - The module, pass it to `register`
- `launchProductSearchRoute(focusesOnAppear:)` - Shows the [Product Search Screen](screens/product_search_screen.md)
- `clearProductGridCache()` - Clears the cached products of product grids (iOS only)
- `IaProductGrid(type:)` - Inline component that shows a grid of products

## ia_ordering

- `IaModuleOrdering()` - The module, pass it to `register`
- `launchCartScreen()` - Shows the [Cart Screen](screens/cart_screen.md)
- `transferPrescriptions(...)` - Adds prescription images, PDFs or eRezept codes to the cart
- `clearCart()` - Removes all products and prescriptions from the cart
- `getCartDetails(...)` - Returns the current cart details (iOS only)
- `getCartState(...)` - Returns the current cart state (iOS only)
- `deleteOrderHistory()` - Deletes the order history (iOS only)
- `orderingDidUpdateCartListener` - Stream of cart updates
- `orderingDidFinishOrderListener` - Stream of finished orders
- `IaCartButton()` - Inline component, a button with the number of items in the cart that opens the cart

## ia_pharmacy

- `IaModulePharmacy()` - The module, pass it to `register`
- `launchPharmacyDetails()` - Shows the [Pharmacy Screen](screens/pharmacy_screen.md)
- `setPharmacyId(pharmacyId)` - Sets the pharmacy, after `initialize`
- `savePharmacyId(pharmacyId)` - Saves the pharmacy without loading it, before `initialize` (iOS only)
- `getPharmacyId()` - Returns the selected pharmacy ID
- `clearPharmacyId()` - Clears the selected pharmacy and empties the cart
- `getPharmacy(...)` - Returns the details of the selected pharmacy (iOS only)

## ia_prescription

- `IaModulePrescription()` - The module, pass it to `register`
- `launchRedeemPrescriptionScreen()` - Shows the [Redeem Prescription Screen](screens/redeem_prescription_screen.md)
- `launchPrescriptionScanner(type)` - Shows the [Prescription Scanner Screen](screens/prescription_scanner_screen.md) (iOS only)
- `setScannerCameraState(...)` - Controls the scanner's camera and flashlight (iOS only)
- `scannerCameraErrorListener` - Stream of scanner camera errors (iOS only)
- `onPrescriptionPhotoScanned` - Lets your app take over a photographed prescription
- `onEPrescriptionScanned` - Lets your app take over a scanned e-prescription

## ia_cardlink

- `IaModuleCardLink()` - The module, pass it to `register`
- `launch(...)` - Starts a CardLink flow
- `finish()` - Finishes the active CardLink session (iOS only)
- `getSavedCardList(userId)` - Returns the user's saved cards
- `getSavedCards(userId)` - Returns the user's saved cards as JSON
- `deleteCard(...)` - Deletes a saved card
- `updateCard(...)` - Replaces the details of a saved card (Android only)
- `reorderSavedCards(...)` - Changes the order of saved cards (Android only)
- `deleteAllCards()` - Deletes all saved cards
- `deleteAllUserRelatedData()` - Deletes all CardLink user data
- `getVersion()` - Returns the CardLink SDK version
- `getEnvironment()` - Returns the CardLink environment
- `getLogFilePath()` - Returns the path of the CardLink log file
- `setHostAppLogFilePath(path)` - Sets your app's log file, attached to CardLink problem reports
- `setMocks(mocks)` - Simulates CardLink backend responses, for testing (iOS only)
- `eventListener` - Stream of CardLink events
- `consentEventListener` - Stream of consent accepted or declined events
- `sessionCreatedListener` - Stream of created CardLink sessions
- `prescriptionsRedeemedListener` - Stream of redeemed prescriptions
- `savedCardsListener` - Stream of saved cards
- `analyticsEventListener` - Stream of CardLink analytics events
- `consentPhoneNumberListener` - Stream of the phone number entered with the consent (iOS only)
- `initializationErrorListener` - Stream of CardLink initialization errors
- `resultListener` - Stream of CardLink results (Android only)
