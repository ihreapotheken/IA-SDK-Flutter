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
  `orderingDidFinishOrderListener`.
- Over the counter: `clearProductGridCache`, `launchProductSearchRoute(focusesOnAppear:)`, `IaProductGrid` custom type,
  `IaCartButton(onTap:)`.
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
- **Android:**
  - `onSdkBackAction` is asked before any SDK screen closes, except through `finishAllActivities`.
  - `launchPrerequisiteFlow` opens the SDK's prerequisites activity.
  - Setters that need an initialized SDK fail before `initialize`.
  - CardLink without an `environment` follows the SDK's environment.

## 0.0.1

* TODO: Describe initial release.
