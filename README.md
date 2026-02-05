# AppSDK Flutter Plugin

Flutter [Plugin](https://flutter.dev/to/develop-plugins) project implemented with the ia.de AppSDK services.

## 1. General Info

---

The plugin implementation is based on the native AppSDK libraries developed by the ia.de team with Kotlin and Swift. 

These native libraries offer both checkout services as well as view components in order to ensure seamless integration 
with any client setup. 

Public API Reference: https://ihreapotheken.github.io/docs/appsdk/flutter

## 2. Developer Setup

---

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.30.0 and up
- [Dart SDK](https://dart.dev/get-dart) 3.10.0 and up
- [Swift Package Manager](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers) Flutter SDK Support
- [Github Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) for native library access

## 3. Platform Support

---

The library is supported on both of the major mobile operating systems, with constraints noted below:

### Android

- Minimum SDK Version: `30`
- Target SDK Version: `36`
- Kotlin `2.1.0`
- Gradle `8.12.3`

### iOS

- Minimum iOS Version: `15`
- Xcode: `16.0`
- Swift `5.9`

## 4. Client Setup

---

For official reference, please see 
[the Flutter SDK documentation](https://docs.flutter.dev/packages-and-plugins/using-packages) 
on using Flutter plugins.

### 4.1. Add the dependency to the `pubspec.yaml` file

The library is accessed from Github as in below example:

```yaml
# pubspec.yaml

environment:
  sdk: '>=3.10.0'
  flutter: '>=3.30.0'

dependencies:
  flutter:
    sdk: flutter
  appsdk_v2_flutter_plugin:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
```

You may reference specific branch, tag, or commit hash by specifying the `ref` field.

Version reference numbers can be found by reviewing 
[the package Github repository tags](https://github.com/ihreapotheken/IA-SDK-Flutter/tags).

### 4.2. iOS Permissions

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

### 4.3. Plugin usage

Methods and properties made available as public APIs implemented with the `IaSdk.instance` object. 

The client setup requires module registration and invocation of the `initialize` method for usage: 

```dart
import 'package:appsdk_v2_flutter_plugin/sdk.dart';

Future<void> initIaSdk() {
  await IaSdk.instance.register(
    modules: [
      // Described in the following section.
    ],
  );
  final iaSdkConfig = IaSdkConfiguration(
    accessKey: 'myAccessKey',
    clientId: 'myClientId',
    serverEnvironment: myServerEnvironment,
  );
  await IaSdk.instance.initialize(
    config: iaSdkConfig,
  );
}
```

Each of the two methods are expected to only be invoked once during the application runtime.

### 4.4. Module registration

Each of the individual native modules are available for installation from the 
[modules](https://github.com/ihreapotheken/IA-SDK-Flutter) directory:

```yaml
# pubspec.yaml

environment:
  sdk: '>=3.10.0'
  flutter: '>=3.30.0'

dependencies:
  flutter:
    sdk: flutter
  appsdk_v2_flutter_plugin:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
  ia_cardlink: # Example module dependency.
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
      path: modules/ia_cardlink
```

After implementing the modules with the `pubspec.yaml` file, 
it's public API declaration object needs to be instantiated, after which it can be forwarded to the `register` method:

```dart
import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:ia_cardlink/ia_cardlink.dart';

final cardLinkModule = IaModuleCardLink();

Future<void> initIaSdk() {
  await IaSdk.instance.register(
    modules: [
      cardLinkModule,
    ],
  );
  
  ...

}
```

Once this is done, the module and it's respective methods and properties 
can be accessed from the `IaSdk.instance` object by accessing it's internal state:

```dart
import 'package:appsdk_v2_flutter_plugin/sdk.dart';

IaSdk.instance.cardLink;
```

For the list of available modules, please visit the [modules](https://github.com/ihreapotheken/IA-SDK-Flutter) directory.

---

For further information, please see the 
[API reference](https://ihreapotheken.github.io/docs/appsdk/flutter) 
and [Usage and Testing documentation](https://ihreapotheken.github.io/docs/appsdk/common/usage-and-testing).