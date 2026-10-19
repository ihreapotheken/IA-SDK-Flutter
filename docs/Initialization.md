# Initialization

Before using any SDK features, you must register the modules and call `initialize`. This is the basic case: once
`initialize` has completed, just show an SDK screen and the SDK takes care of the rest. In the sections below, we'll
cover more advanced scenarios.

```dart
await IaSdk.instance.register(
  modules: [
    IaModuleOverTheCounter(),
    IaModuleOrdering(),
  ],
);

await IaSdk.instance.initialize(
  config: IaSdkConfiguration(
    accessKey: 'ENTER YOUR API KEY HERE',
    clientId: 'ENTER YOUR CLIENT ID HERE',
    serverEnvironment: IaSdkConfigurationServerEnvironment.production,
    initialization: const IaSdkConfigurationInitialization(
      shouldShowIndicator: true,
      prerequisites: IaPrerequisitesConfiguration(
        runLegalIfNeeded: true,
        runOnboardingIfNeeded: true,
        runApofinderIfNeeded: true,
      ),
    ),
  ),
);

// Prerequisites screens are shown automatically, if needed, before the start screen.
await IaSdk.instance.launchStartRoute();
```

Calling `initialize` will do the following:
* Validate your API key and fetch the entitlements (permissions) for your modules.
* Fetch the remote configuration (your legal data, onboarding, feature flags, remote colors etc.).
* Store the `prerequisites` options, used later when the prerequisites run.

Calling `initialize` doesn't show any screens, except for a loading indicator when `shouldShowIndicator` is `true`.

The prerequisites are a flow of screens that runs before the user can use the SDK:
* **Onboarding:** An introductory onboarding screen, shown only once. Onboarding is optional, you can set
  `runOnboardingIfNeeded` to `false` to skip it.
* **Legal Opt-In:** The user must opt in to use the SDK. This is presented the first time and when the version of some
  legal document changes. If your app has its own legal screens, you can set `runLegalIfNeeded` to `false`.
* **Apofinder:** The SDK requires a pharmacy to be set. It cannot run without one. You can provide the pharmacy in two
  ways:
    * Manually provide a pharmacy identifier with `IaSdk.instance.pharmacy.setPharmacyId(...)` (from the `ia_pharmacy`
      module) after `initialize` has completed.
    * Let the prerequisites present **Apofinder**. This will allow the user to select a pharmacy from a list or map.

## Initialization and prerequisites explained
The initialization process can be divided into two key parts:
- SDK initialization: Fetches and configures essential components of the SDK. This step has no UI, except for a
  loading indicator. This is what `initialize` does.
- Prerequisites: A flow of screens that runs only when necessary. While onboarding and legal steps are optional, this
  phase ensures that the pharmacy is set, which is mandatory.

The prerequisites flow can be run in two ways:
- **Automatically (recommended):** When you show any SDK screen, the SDK first runs the prerequisites that are still
  needed, and then shows the screen. You don't need to do anything for this, both the iOS and the Android SDK do it.
- **Explicitly (optional):** By calling `launchPrerequisiteFlow`, when you want the prerequisites to run at a specific
  moment.

Regardless of how many times the prerequisites are triggered, the screens are presented only if needed (the first
time, or when something changed, e.g. a new version of a legal document).

## Automatic prerequisites (recommended)
The preferred way is to call `initialize` and then simply show SDK screens, e.g. `launchStartRoute()`. The
prerequisites run with the options you passed in `IaSdkConfigurationInitialization.prerequisites`.

```dart
await IaSdk.instance.initialize(config: config);

// Later, when the user enters the part of your app where IA SDK is used.
await IaSdk.instance.launchStartRoute();
```

However, it's important to note that the prerequisites only run automatically when a screen is shown. If you call an
SDK function that requires the prerequisites (e.g. a selected pharmacy) before showing any screen, it will not run them.
In that case, run them explicitly first.

## Running prerequisites explicitly (optional)
Call `launchPrerequisiteFlow` after `initialize` has completed. It shows only the steps that are still needed and
returns right away when all of them are done. Don't show SDK screens or components until it has returned.

```dart
final result = await IaSdk.instance.launchPrerequisiteFlow();
if (!result.isCancelled) {
  // Proceed with SDK, e.g. IaSdk.instance.launchStartRoute();
}
```

When `isCancelled` is `false`, the prerequisites are completed and a pharmacy is selected (unless
`runApofinderIfNeeded` is `false`). When the user cancelled the flow, you must not show any IA SDK screens or
components.

## Initialization state
You can check the current state with `getInitializationState()` or `isInitialized()`, and listen to changes with
`initializationStateListener`:

```dart
IaSdk.instance.initializationStateListener.stream.listen((state) {
  // uninitialized, initializing, initialized or error.
});
```

## Common scenarios
Here we will cover some common scenarios and how to best handle initialization and prerequisites.

**Scenario 1:** IA SDK is a vital part of your app and you don't mind that the prerequisites screens are shown when
the app starts.  
Call `register` and `initialize` at start, followed by `launchPrerequisiteFlow`. You can then use IA SDK screens and
functions as you wish.  
If something fails, you must handle it at start.

**Scenario 2:** You run IA SDK from a single entry point and don't use any IA SDK functions before.  
Call `register` and `initialize` at start, or just before the user enters the part of your app where IA SDK is used.
Then simply show an SDK screen, e.g. `launchStartRoute()`, and the prerequisites run automatically.  
This is the recommended setup. See the `singleEntryPoint` flavor of the [example app](../example/README.md).

**Scenario 3:** You run IA SDK from a single entry point, but you might call some IA SDK functions before it.  
Call `register` and `initialize` at start of your app. Most functions can be used after `initialize`. If some function
requires a pharmacy to be set, call `launchPrerequisiteFlow` before it (or set the pharmacy with `setPharmacyId`).

## Other
To reset or skip certain steps, use the following code:

```dart
// Sets the pharmacy to none and resets the legal documents and onboarding flags.
await IaSdk.instance.resetPrerequisites();

// Marks the legal documents as not accepted. iOS only.
await IaSdk.instance.resetLegalDisclaimer();

// Marks the onboarding step as shown, so it won't be shown again. iOS only.
await IaSdk.instance.setIsOnboardingShown(isOnboardingShown: true);

// Cleans the prerequisites cache. iOS only.
await IaSdk.instance.cleanCache(prerequisites: true);

// Sets the pharmacy ID, after initialize. Requires the ia_pharmacy module.
await IaSdk.instance.pharmacy.setPharmacyId('12345');

// Saves the pharmacy ID without loading it, before initialize. iOS only, requires the ia_pharmacy module.
await IaSdk.instance.pharmacy.savePharmacyId('12345');

// Whether the prerequisites are completed. Android only.
final isCompleted = await IaSdk.instance.isPrerequisiteFlowCompleted();
```

## Platform differences
The plugin keeps both platforms as close as possible, but the native SDKs differ in a few places:

- **Calling `initialize` again:** On iOS, a later call after a failed `initialize` initializes the SDK again. On
  Android the SDK initializes only once.
- **Cancelling prerequisites:** On iOS they can be made cancellable with `isCancellable`; on Android they always are.
- **Helpers:** `resetLegalDisclaimer`, `setIsOnboardingShown`, `cleanCache` and `savePharmacyId` are iOS only,
  `isPrerequisiteFlowCompleted` is Android only. They throw a `MissingPluginException` on the other platform.
