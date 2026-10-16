## Unreleased

Native SDK 2.9.0 on both platforms.

### Added

- Native APIs that weren't proxied yet, on both platforms where the native SDKs have them. Members only one native
  SDK has are documented as "Only supported on iOS/Android"; calling such a method on the other platform throws a
  `MissingPluginException`. See the doc comments of `IaSdk` and the module classes.
- `IaSdk`: `resetPrerequisites`, `resetLegalDisclaimer`, `setIsOnboardingShown`, `isPrerequisiteFlowCompleted`,
  `launchPrerequisiteFlow`, `clearUserBillingAddress`, `clearUserDeliveryAddress`, `setAnalyticsConsent`,
  `setHapticFeedbackEnabled`, `presentLogs`, `exportLogs`, `getUserId`, `removeAllCachedResponses`,
  `getInitializationState`, `onSdkBackAction`, and the streams `initializationStateListener`,
  `analyticsEventListener` and `logMessageListener`. `launchPrerequisiteFlow` runs the prerequisites flow on both
  platforms and returns whether the user cancelled it.
- `IaSdkConfiguration`: `isPickupLockerAndCourierShippingEnabled`, `appStoreId`, `playStoreId`, `isAnalyticsEnabled`,
  `isHapticFeedbackEnabled`, `qaConfiguration`, `cardLink`, `hostAppLogFilePath`, and
  `IaSdkConfigurationFooter.isImprintHandledByHostApp`.
- Pharmacy: `clearPharmacyId`, `savePharmacyId`, `getPharmacy`.
- Ordering: `getCartState`, `getCartDetails` options, `transferPrescriptions` `finishAction` and
  `showActivityIndicator`, cart counts and products in `orderingDidUpdateCartListener`, `orderCodes` in
  `orderingDidFinishOrderListener`, `IaCartButton(onTap:)`.
- Over the counter: `clearProductGridCache`, `launchProductSearchRoute(focusesOnAppear:)`, `IaProductGrid` custom
  type.
- Prescription: scan interception (`onPrescriptionPhotoScanned`, `onEPrescriptionScanned`),
  `launchPrescriptionScanner`, `setScannerCameraState`, `scannerCameraErrorListener`.
- CardLink: `getSavedCardList`, `updateCard`, `reorderSavedCards`, `setHostAppLogFilePath`, `setMocks`,
  `illustrationColor`, and the streams `consentPhoneNumberListener`, `savedCardsListener`,
  `initializationErrorListener` and `resultListener`.
- Navigation targets reported on Android: `start`, `search`, `redeemPrescription`, `thankYouCompleted`.
- Example app: an Events tab with all callbacks and switchable host answers, and buttons for the new APIs. Buttons
  for single-platform APIs only show on their platform.

### Fixed

- `onSdkWillNavigateToTarget` never ran: the handler rejected the arguments both platforms send.
- Native callbacks reach Dart without a constructed module, and `IaSdk.instance` no longer needs the Flutter
  binding.
- Android: custom UI colors were decoded as packed Compose values instead of ARGB.
- Android: cart, order and scan callbacks stopped after the Flutter engine was recreated.
- Android: `initialize` reported success while the SDK was still initializing or had failed.
- Android: `channelId` was ignored, `transferPrescriptions` could reply twice or never, and calls before `register`
  threw.
- CardLink: the session and saved-card events, the saved-card CAN code, and iOS CardLink reopening.
- Errors in Dart callback handlers are logged instead of swallowed.
- Android: `IaSdkConfigurationQa.apofinderCustomPharmacyId` never reached the SDK.
- iOS: `finishAllActivities` closed every presented screen, including the host's. It now closes the SDK screens,
  like Android.
- iOS: NaN or infinite numbers in the configuration crashed `initialize`; they now fail with `ARG_ERROR`, and
  argument errors name the field.
- `IaProductGrid` kept its first options; changed options now recreate the native grid.
- Inline components didn't shrink to empty, and didn't grow when more width became available.
- CardLink on iOS:
  - With the `uploadPrescriptions` finish action, the added prescriptions and `willExit` weren't reported.
  - `launch` reset the SDK-wide color palette. Without colors it's now kept; passed colors last until CardLink
    closes.
  - `getSavedCards` reported storage errors as no cards, `getLogFilePath` returned a `file://` URL or `""`, and
    `finish` never completed when no CardLink was shown.
  - The configured phone number of SDK-started flows wasn't cleaned up like a launched one.
- CardLink on Android: `getEnvironment` reported production before the first launch, and `willExit` came too early
  when the app was paused while CardLink was signing in.
- Module callbacks no longer pile up when a module is created more than once.
- `ia_cardlink` declares its `ia_interface` dependency.
- iOS: `launchApofinder` didn't report the selected pharmacy through `onApofinderDidChangePharmacy` and didn't close.
- iOS: `resetPrerequisites`, `resetLegalDisclaimer`, `setIsOnboardingShown` and `clearPharmacyId` only took effect
  after an app restart.
- Android: inline components crashed in apps using `FlutterActivity`. They now fail with an error instead, see
  Changed.
- Inline components failed to lay out without a width limit, for example in a `Row` or `AppBar.actions`.
- iOS: an empty product grid kept its loading height, and components took an endless height while the SDK showed
  its loading or error view.
- Android: the `IaCartButton` without `onTap` opened the cart without asking `onSdkWillNavigateToTarget`.
- iOS: `cleanCache(initialization: true)` left `initialize` doing nothing, an initialization retry reported
  `error` instead of `initializing`, and a second `initialize` call during the first failed.
- `getCartDetails` returns nested maps with `String` keys.
- CardLink on iOS: the privacy link on the consent screen closed CardLink without `willExit` and kept the launch
  colors for all SDK screens; a CardLink flow closed by `finishAllActivities` now reports `willExit`; the cart and
  terms events of SDK-started flows are reported; deleting a card that isn't saved no longer fails; a failed
  continuation from the saved cards screen now reports `willExit`, and a failed launch no longer leads to one.
- CardLink on Android: a failed scan-flow sign-in from the saved cards screen stopped all later `willExit` events,
  `getLogFilePath` returned a path when there was no log file, and a CardLink flow the SDK started soon after the
  saved cards screen closed was reported as the launched one.
- Android: `transferPrescriptions` with `openCart` or `noAction` never completed.
- Android: `setPharmacyId` trims the ID and rejects non-numeric IDs with `ARG_ERROR`, as on iOS.
- Android: closing the transfer screen during the upload left `transferPrescriptions` pending, or completed it later
  without the prescriptions in the cart. The call now fails.
- iOS: `setGuestUserData` passed the phone country code without "+", so checkout saved addresses with a wrong one.
- `initialize` with an empty `accessKey` or `clientId` fails with `ARG_ERROR` on both platforms. Android used to
  leave the initialization state at `uninitialized`.
- Android: `finishAllActivities` left the overlay of a `showBottomSheet` prescription transfer open.
- CardLink on iOS: closing a CardLink launched with colors while `initialize` finished replaced the remote theme,
  or kept the CardLink colors without one; a launch without an `environment` kept the one of an earlier launch
  instead of the `IaSdk` one.
- Android: `setPharmacyId` before `initialize` fails with `SDK_NOT_INITIALIZED`, and its other errors no longer
  show an object hash.
- iOS: an SDK screen launched while `initialize` was running, a retry included, kept loading. It now opens once
  initialization is done.
- iOS: retrying `initialize` while an SDK screen ran the initialization and prerequisites itself failed with
  `INIT_ERROR`. The retry now waits for them.
- iOS: `clearPharmacyId` left the cart of the cleared pharmacy, which Android empties.
- Android: `orderingDidUpdateCartListener` didn't report the cart emptied by `clearCart` or `clearPharmacyId`.
- Android: closing the confirmation sheet of a `showBottomSheet` prescription transfer opened the cart.
- Android: `logout` kept the cart, which iOS empties.
- CardLink on iOS: a launch without an `environment` could undo the environment `initialize` set after an earlier
  launch with one.
- CardLink on iOS: the configured `IaSdkConfigurationCardLink.phoneNumber` replaced the number of a picked saved
  card; `finish` right after `launch` reported `willExit` for a flow that still opened; a launch without a screen to
  show on kept the launch colors.
- Android: the prerequisite screens the SDK opens itself drew behind the navigation bar. In apps without a theme of
  their own, such as the Flutter template, they also drew behind the status bar, and the debug viewer showed an extra
  bar with the app's name.
- Android: `orderingDidUpdateCartListener` repeated an update when the SDK loaded an unchanged cart again, for
  example twice after a prescription transfer.

### Changed

- **`IaSdkNavigationTarget`, `IaCardLinkEvent` and `IaProductDisplayType` have new values.** Exhaustive `switch`
  statements over them need the new cases.
- **The `IaBase*` interfaces have new abstract members**, and `getCartDetails`, `launchProductSearchRoute`,
  `launchApofinder` and `IaBaseViews.launch` take new optional parameters. Classes implementing these interfaces or
  overriding `launch` need updating.
- **`onSdkWillNavigateToTarget` now runs.** Return `true` for targets the SDK should handle itself.
- **iOS no longer lists test pharmacies in Apofinder by default.** Pass
  `IaSdkConfigurationQa(showTestPharmaciesInApofinder: true)` for that.
- **Android follows `IaSdkConfigurationFooter.shouldShowDataProcessing`**, which defaults to `true`, as on iOS.
- **Unknown salutations are stored as "Keine Angabe"** on both platforms. iOS used to reject them.
- **`setGuestUserData` takes `phoneNumberWithoutCountryCode` as a `String`**, like the address setters, so leading
  zeros are kept.
- **`IaModelOrderingTransactionSignatures.clientOrderIDs` is no longer nullable**; it's empty without order IDs.
- **`register` waits for the native part of each module** and fails when one is missing. A later call that adds
  modules throws a `StateError`; pass all modules in the first call.
- **`register` has to come before `initialize`**, and throws a `StateError` afterwards: the Android SDK only starts
  the modules registered before it initializes. `initialize` waits for a `register` call that's still running, and
  a `register` call made while another one runs waits for it, then counts as a later call.
- **CardLink `launch` takes `supportsLiquidGlass` as an optional `bool?`**; without it the `initialize` setting is
  kept.
- **`setAnalyticsConsent` takes `consent` as a named parameter**, like the other setters.
- **`getEnvironment` returns a non-null `IaSdkConfigurationServerEnvironment`.**
- **Android error codes name the failed method**, for example `CLEAR_CART_ERROR`, as on iOS, instead of
  `METHOD_ERROR`.
- **`exportLogs` returns a non-null path** and fails when the logs can't be exported.
- **CardLink error codes name the failed method on both platforms**, for example `GET_SAVED_CARDS_ERROR`, instead of
  `STORAGE_ERROR`, `ENCODING_ERROR` or `JSON_ERROR`.
- **Android inline components need a `ComponentActivity`**, such as `FlutterFragmentActivity`, as the app's activity.
- **Android:**
  - `onSdkBackAction` is asked before any SDK screen closes, except through `finishAllActivities`.
  - Calls that need an initialized SDK fail before `initialize`: the address setters, `setGuestUserData`, `logout`,
    `resetPrerequisites`, `isPrerequisiteFlowCompleted`, `setAnalyticsConsent`, `setHapticFeedbackEnabled`,
    `clearCart`, `transferPrescriptions`, `presentLogs`, `exportLogs`, and the pharmacy ID getter and clearer. The
    SDK used to ignore them or answer with defaults.
  - CardLink without an `environment` follows the SDK's environment.
- **The Android plugins need API 27 (Android 8.1) instead of 30**, like the native SDK modules. `ia_cardlink` still
  needs API 30, as the native CardLink module does.

## 0.0.1

* TODO: Describe initial release.
