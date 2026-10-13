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
  `prerequisitesResultListener`, `analyticsEventListener` and `logMessageListener`.
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
- Example app: an Events tab with all callbacks and switchable host answers, and buttons for the new APIs.

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
- Android: inline components crashed in apps using `FlutterActivity` instead of `FlutterFragmentActivity`.
- Inline components failed to lay out without a width limit, for example in a `Row` or `AppBar.actions`. The
  Android cart button now has its own width, as on iOS.
- iOS: an empty product grid kept its loading height.
- Android: the `IaCartButton` without `onTap` opened the cart without asking `onSdkWillNavigateToTarget`.

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
- **CardLink `launch` takes `supportsLiquidGlass` as an optional `bool?`**; without it the `initialize` setting is
  kept.
- **`setAnalyticsConsent` takes `consent` as a named parameter**, like the other setters.
- **`getEnvironment` returns a non-null `IaSdkConfigurationServerEnvironment`.**
- **Android error codes name the failed method**, for example `CLEAR_CART_ERROR`, as on iOS, instead of
  `METHOD_ERROR`.
- **Android:**
  - `onSdkBackAction` is asked before any SDK screen closes, except through `finishAllActivities`.
  - `launchPrerequisiteFlow` opens the SDK's prerequisites activity.
  - Calls that need an initialized SDK fail before `initialize`: the address setters, `setGuestUserData`, `logout`,
    `resetPrerequisites`, `isPrerequisiteFlowCompleted`, `setAnalyticsConsent`, `setHapticFeedbackEnabled`,
    `clearCart`, `transferPrescriptions`, and the pharmacy ID getter and clearer. The SDK used to ignore them or
    answer with defaults.
  - CardLink without an `environment` follows the SDK's environment.

## 0.0.1

* TODO: Describe initial release.
