# IA SDK Flutter

IA SDK Flutter is a Flutter plugin that helps integrate IhreApotheken into your app by providing plug-and-play UI and communication with backend services.

The plugin is a thin wrapper around the native IA SDKs for [iOS](https://github.com/ihreapotheken/IA-SDK-iOS) and [Android](https://github.com/ihreapotheken/IA-SDK-Android). It exposes their functionality and screens to Dart.

Like the native SDKs, the plugin is split into packages:
* **appsdk_v2_flutter_plugin**: Core package, required. Legal, onboarding, start screen, Apofinder (pharmacy search with list and map).
* **ia_over_the_counter**: Product search, product details, inquiry.
* **ia_ordering**: Cart, checkout, payment.
* **ia_pharmacy**: Pharmacy details.
* **ia_prescription**: Prescription scanner.
* **ia_cardlink**: Scanning prescriptions from electronic health cards.

To use IA SDK, you will need an API key and Client ID. The API key is bound to specific app Bundle ID(s) / Application ID(s) and comes with a set of entitlements. Each entitlement enables access to certain features or services within the SDK.

Public API Reference: https://ihreapotheken.github.io/docs/appsdk/flutter

## 1. Developer Setup

---

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.30.0 and up
- [Dart SDK](https://dart.dev/get-dart) 3.10.0 and up
- [Swift Package Manager](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers) Flutter SDK Support
- [Github Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) for native library access

## 2. Platform Support

---

The library is supported on both of the major mobile operating systems, with constraints noted below:

### Android

- Minimum SDK Version: `27` (Android 8.1), or `30` (Android 11) with `ia_cardlink`, like the native CardLink module
- Target SDK Version: `36`
- Kotlin `2.1.0`
- Gradle `8.12.3`
- The inline components (`IaCartButton`, `IaProductGrid`) need the app's activity to be a `ComponentActivity`, such as
  `FlutterFragmentActivity`.

### iOS

- Minimum iOS Version: `15`
- Xcode: `16.0`
- Swift `5.9`

## 3. Client Setup

---

For official reference, please see 
[the Flutter SDK documentation](https://docs.flutter.dev/packages-and-plugins/using-packages) 
on using Flutter plugins.

### 3.1. Add the dependencies to the `pubspec.yaml` file

Add the core package, `appsdk_v2_flutter_plugin`, and the module packages you need. All packages are fetched from GitHub;
the modules live in the [modules](modules) directory.

> [!IMPORTANT]
> Add only the module packages that you will use and for which your API key has entitlements.

> [!IMPORTANT]
> Set `ref` to the latest version tag, not `main`, and use the same `ref` for the core package and all modules.
> The available tags are listed in [the package Github repository tags](https://github.com/ihreapotheken/IA-SDK-Flutter/tags).

```yaml
# pubspec.yaml

environment:
  sdk: '>=3.10.0'
  flutter: '>=3.30.0'

dependencies:
  flutter:
    sdk: flutter

  # Core package, required.
  appsdk_v2_flutter_plugin:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main

  # Module packages, optional. Add only the ones you need.
  ia_over_the_counter:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
      path: modules/ia_over_the_counter
  ia_ordering:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
      path: modules/ia_ordering
  ia_pharmacy:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
      path: modules/ia_pharmacy
  ia_prescription:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
      path: modules/ia_prescription
  ia_cardlink:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
      path: modules/ia_cardlink
```


### 3.2. iOS Permissions

Add the following keys to your `Info.plist` file based on the modules you use:

```xml
<!-- Location permission - required for Apofinder (pharmacy finder) module -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to show pharmacies nearby.</string>

<!-- Camera permission - required for Prescription (RX) module -->
<key>NSCameraUsageDescription</key>
<string>Camera access is needed for prescription upload.</string>

<!-- NFC permission - required for CardLink module -->
<key>NFCReaderUsageDescription</key>
<string>NFC is used to read your health insurance card for prescription redemption.</string>
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>D2760001448000</string>
    <string>D27600014601</string>
    <string>D27600014606</string>
    <string>D27600000102</string>
    <string>A000000167455349474E</string>
    <string>D27600006601</string>
    <string>D27600014602</string>
    <string>E828BD080FA000000167455349474E</string>
    <string>E828BD080FD27600006601</string>
    <string>D27600014603</string>
</array>
```

| Permission | Key | Required For | Purpose |
|------------|-----|--------------|---------|
| Location (When In Use) | `NSLocationWhenInUseUsageDescription` | Apofinder module | Find nearby pharmacies and get directions |
| Camera | `NSCameraUsageDescription` | Prescription (RX) module | Scan and upload prescriptions via camera |
| NFC | `NFCReaderUsageDescription` | CardLink module | Read health insurance cards via NFC for prescription redemption |

**Note:** The `com.apple.developer.nfc.readersession.iso7816.select-identifiers` key with the listed AIDs is required for CardLink to communicate with German health insurance cards (eGK) and related secure messaging protocols.

### 3.3. Plugin usage

1. **Set the app identifier**  
The API key is linked to your app's identifier, so set it on both platforms:
   - iOS: the bundle identifier, in the Runner target's Build Settings (`PRODUCT_BUNDLE_IDENTIFIER`).
   - Android: the `applicationId`, in `android/app/build.gradle(.kts)`.

2. **Import the required packages**  
`appsdk_v2_flutter_plugin` is mandatory, the module packages are optional. In this example we will be using product
search from `ia_over_the_counter` and cart from `ia_ordering`.
```dart
import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:ia_over_the_counter/ia_over_the_counter.dart';
import 'package:ia_ordering/ia_ordering.dart';
```

3. **Register modules**  
The first step is to register all the modules you plan to use. This must be done before calling any other function
or presenting any screens, so we recommend doing it right when the app starts.
This step is required because modules can be interconnected. For example, registering `IaModuleOrdering` makes the
**Cart** feature (from `ia_ordering`) internally available to the **Product Search** feature (from
`ia_over_the_counter`), enabling features like a cart button on the search screen.
Integrations and Apofinder are part of the core package and are always registered.
```dart
await IaSdk.instance.register(
  modules: [
    IaModuleOverTheCounter(),
    IaModuleOrdering(),
  ],
);
```
> [!IMPORTANT]
> Register all modules in one call, before `initialize`. 

Registered modules are then available on `IaSdk.instance`, for example `IaSdk.instance.overTheCounter` and
`IaSdk.instance.ordering`.

4. **Basic setup and initialize**  
Next, enter your API key, client ID and other options you might need in `IaSdkConfiguration`, and pass it to
`initialize`. This fetches all required data and enables your modules. Call it once, right after `register`.
```dart
await IaSdk.instance.initialize(
  config: IaSdkConfiguration(
    accessKey: 'ENTER YOUR API KEY HERE',
    clientId: 'ENTER YOUR CLIENT ID HERE',
    serverEnvironment: IaSdkConfigurationServerEnvironment.production,
    initialization: const IaSdkConfigurationInitialization(
      shouldShowIndicator: true,
      prerequisites: IaPrerequisitesConfiguration(
        isCancellable: false,       // iOS only
        isAnimated: true,           // iOS only
        runLegalIfNeeded: true,
        runOnboardingIfNeeded: true,
        runApofinderIfNeeded: true,
      ),
    ),
  ),
);
```
> [!TIP]
> To learn more about initialization, see [Initialization](docs/initialization.md).

## 4. Guides

[Initialization](docs/initialization.md)  
[Presentation](docs/presentation.md)  
[Appearance](docs/appearance.md)  
[SDK Interaction](docs/interaction.md)

## 5. Screens

[Start Screen](docs/screens/start_screen.md)

## 6. Demo App Deployment

---

The example app is distributed to testers through Firebase App Distribution (Android) and TestFlight (iOS), by the
deploy scripts or the [Demo App Deploy](.github/workflows/demo_app_deploy.yml) workflow:

```bash
sh ./scripts/deploy-demo.sh           # Android and iOS
sh ./scripts/deploy-demo-android.sh   # Android only
sh ./scripts/deploy-demo-ios.sh       # iOS only
```

The scripts take no arguments. Environment variables, set in front of the command, select what's deployed:

| Variable | Values | Default |
|---|---|---|
| `IA_FLAVOR` | The [example app flavor](example/README.md#flavors): `demo` or `singleEntryPoint` | `demo` |
| `IA_SERVER_ENV` | The backend: `development`, `staging` or `production` | `staging` |

```bash
IA_FLAVOR=singleEntryPoint sh ./scripts/deploy-demo.sh
IA_SERVER_ENV=production sh ./scripts/deploy-demo-android.sh
IA_FLAVOR=singleEntryPoint IA_SERVER_ENV=production sh ./scripts/deploy-demo-ios.sh
```

Every flavor is delivered as the same app, with the same signing and the same Firebase and TestFlight app. Only the
launcher name tells them apart.

On GitHub, run the Demo App Deploy workflow and choose the platform and the flavor. A pushed tag deploys the `demo`
flavor to both platforms.

---

For further information, please see the 
[API reference](https://ihreapotheken.github.io/docs/appsdk/flutter) 
and [Usage and Testing documentation](https://ihreapotheken.github.io/docs/appsdk/common/usage-and-testing).