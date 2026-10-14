# IA SDK Flutter Plugin Example

This example app demonstrates how to integrate and use the IA SDK Flutter plugin.

## Prerequisites

- Flutter >= 3.30.0
- Dart SDK >= 3.10.0
- iOS or Android development environment set up

## Environment Setup

The example app requires an SDK access key to authenticate with the ia.de backend services.

### Option 1: Using a .secrets file (Recommended)

1. Create a `.secrets` file in the `example/` directory:
   ```
   APPSDK_ACCESS_KEY=your_access_key_here
   ```

2. The `.secrets` file is already included in `.gitignore` and will not be committed to source control.

### Option 2: Using dart-define

Pass the access key as a compile-time variable:
```bash
flutter run --dart-define iaAccessKey=your_access_key_here
```

### Server environment

The backend the app talks to is selected with the `iaServerEnv` dart-define, using the
`IaSdkConfigurationServerEnvironment` value names. It defaults to `staging` (QA):

```bash
flutter run --dart-define iaServerEnv=development   # DEV
flutter run --dart-define iaServerEnv=staging       # QA  (default)
flutter run --dart-define iaServerEnv=production    # PROD
```

### Pharmi mascot illustrations

`IaUIConfiguration.shouldShowMascotIllustrations` controls whether the Pharmi mascot
is rendered. It defaults to `true` and is read while the SDK initializes:

```bash
flutter run --dart-define iaShowMascot=false
```

The two platforms differ in what can be changed afterwards:

- **iOS** — also settable at runtime with `IaSdk.setShouldShowMascotIllustrations`.
  The Services tab has a "Hide/Show mascot illustrations (iOS)" button for this.
- **Android** — the native `IAUIConfiguration` is immutable once the SDK is
  initialized, so `iaShowMascot` is the only way to change it, and the runtime
  button reports `MissingPluginException` by design.

Either way, CardLink → FAQ is the screen that renders the mascot, so that is where
to check the result.

Requires AppSDK 2.7.0 or newer on both platforms.

### Test switches

These dart-defines turn on SDK options the app leaves off by default, so they can be tested:

| dart-define | Effect | Default |
|---|---|---|
| `iaShowDataProcessing=true` | Footer shows "Datenverarbeitung", reported as the `hostAppPrivacyPolicy` navigation target | off |
| `iaHostImprint=true` | Android: the imprint button is reported as the `imprint` navigation target instead of opening the SDK's page | off |
| `iaPickupLocker=true` | Checkout offers pickup lockers and courier shipping | SDK default |
| `iaAnalytics=false` | Android analytics tracking (events show in the Events tab once consent is granted) | on outside production |
| `iaAppStoreId=…`, `iaPlayStoreId=…` | Store identifiers the SDK links to | unset |

Test pharmacies are listed in Apofinder outside production (`IaSdkConfigurationQa`). CardLink flows the SDK
starts itself save cards under the CardLink tab's default user ID, and problem reports include a demo host log file.

## Running the Example

```bash
cd example
flutter pub get
flutter run
```

## App Identity

The demo app carries the same launcher branding as the native demo apps
([IA-SDK-Dev-Android](https://github.com/ihreapotheken/IA-SDK-Android),
[IA-SDK-Dev-iOS](https://github.com/ihreapotheken/IA-SDK-iOS)):

- **Android** — the IA pin adaptive icon (`mipmap-anydpi-v26/ic_launcher.xml` over the
  `ic_launcher_background` colour), copied from the native Android demo app.
- **iOS** — the `IA SDK` wordmark app icon, generated from the native iOS demo app's
  1024×1024 artwork.

The launcher label is `AppSDK Flutter Demo` followed by the environment the build
targets, so a distributed build is identifiable without opening it — for example
`AppSDK Flutter Demo QA`. The same tag is shown in the app bar next to the native
AppSDK version.

The tag is derived from the `IA_SERVER_ENV` shell variable (`production` → `PROD`,
`staging` → `QA`, `development` → `DEV`, default `staging`), which
[dev-env-setup.sh](../scripts/dev-env-setup.sh) exports for the deploy scripts:

```bash
IA_SERVER_ENV=production sh ./scripts/deploy-demo.sh
```

The deploy scripts pass the same value on as `--dart-define=iaServerEnv`, so the label
and the app's actual backend can never disagree. Android reads `IA_SERVER_ENV` in
[app/build.gradle.kts](android/app/build.gradle.kts) to generate the `app_name`
resource; iOS reads `IA_ENV_LABEL` from [ios/Flutter/IAEnv.xcconfig](ios/Flutter/IAEnv.xcconfig)
in `CFBundleDisplayName`, which
[deploy-demo-ios.sh](../scripts/deploy-demo-ios.sh) rewrites before archiving.

## App Structure

The example app contains six tabs demonstrating different SDK features. Labels ending in "(iOS)" or
"(Android)" mark features only one native SDK has; on the other platform they report a `MissingPluginException`.

### Host App Tab
Displays a map with pharmacy markers. Tapping a marker shows a bottom sheet where you can:
- Select a pharmacy by ID
- Launch the SDK start route
- Open a web browser overlay

### CardLink Tab
Demonstrates the CardLink module for NFC-based prescription transfer:
- Launch the CardLink and Saved Cards flows, with an illustration color (Android)
- Get SDK version, environment and log file info
- Manage saved cards: get (raw and typed), rename (Android), reorder (Android), delete, mock the backend (iOS)
- Attach a host log file to problem reports
- A log of all CardLink events, including consent phone number, saved cards, errors and results

### Services Tab
Demonstrates the SDK service methods:
- SDK state: initialization state, environment, prerequisites (reset, legal disclaimer, onboarding)
- Pharmacy: get, save without validation (iOS), clear, details (iOS)
- Ordering: cart details and state (iOS), clear cart, order history, transfer prescriptions with each finish action
- User: guest data, billing and delivery addresses (set and clear), delete user, logout
- Appearance, analytics consent, haptics, logs, user ID and caches

### Screens Tab
Demonstrates launching SDK screens directly: start, product search (also focused), cart, pharmacy details,
Apofinder (also not cancellable), redeem prescription, the prescription scanners with a scripted camera test
(iOS), and the prerequisite flow (Android).

### Components Tab
Embeds the cart button (also with a host tap handler) and the product grids, including a custom one.

### Events Tab
Lists the SDK callbacks and stream events the app received: navigation targets, back actions, initialization
state, prerequisites results, cart and order updates, scanned prescriptions, analytics, CardLink events and,
when switched on, the SDK's own log messages (iOS). Switches at the top change how the app answers:
- the host handles navigation targets, so the SDK doesn't open the screen,
- the back action keeps SDK screens open (Android),
- the answer to scanned prescriptions (perform default, handled, error).

## E2E Harness

The app can boot into a harness used by the shared e2e-tests suite instead of the
demo UI:

```bash
flutter run --dart-define=iaE2E=true
flutter build apk --debug --dart-define=iaE2E=true
flutter build ios --simulator --debug --dart-define=iaE2E=true
```

The harness ([lib/src/e2e/](lib/src/e2e/)) mirrors the native demo apps: a host
tab bar (Start / Search / Cart / Pharmacy / Settings) over full-screen embedded
SDK screens. Because the SDK content is the same native UI in every host, the test
flows and their selectors are shared across the native demo app and this one.

Notes:

- Prerequisites (onboarding → legal → Apofinder) are driven by the SDK when the
  start screen is shown without them completed, so a fresh install reproduces the
  same entry sequence the demo apps show.
- Host controls carry `Semantics` identifiers (`tab_start`, `tab_cart`,
  `host_use_test_pharmacy`, …), which reach the test runner as `resource-id` on
  Android and `accessibilityIdentifier` on iOS. Renaming one means updating
  `_elements.flutter.yaml` in the e2e-tests repo.
- The Settings tab selects test pharmacy 2163 via `setPharmacyId`, standing in for
  the demo app's QA-only "Apotheken-ID eingeben" sheet.
- `--dart-define=iaE2EPharmacyId=2163` optionally pre-selects a pharmacy before
  the harness appears, which skips the Apofinder prerequisite entirely.

## SDK Initialization

The SDK is initialized in [sdk_initializer.dart](lib/src/services/sdk_initializer.dart). The initialization process includes:

1. **Setting up callbacks** - Handle SDK navigation events
2. **Registering modules** - CardLink, Ordering, OverTheCounter, Pharmacy, Prescription
3. **Initializing the SDK** - Pass configuration with access key
4. **Setting up event listeners** - Listen for ordering and CardLink events

## Configuration

SDK configuration is managed in [ia_client_config.dart](lib/ia_client_config.dart). Key configuration options include:
- `accessKey` - Authentication key (from .env or dart-define)
- `clientId` - Client identifier
- `serverEnvironment` - Backend environment (debug/production)
