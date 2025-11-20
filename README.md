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

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.3 and up
- [Dart SDK](https://dart.dev/get-dart) 3.9.2 and up
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

### 4.1. Source control access

In order to enable 

### 4.2. Add the dependency to the `pubspec.yaml` file

The library is accessed from Github as in below example:

```yaml
# pubspec.yaml

environment:
  sdk: ^3.9.2
  flutter: '>=3.3.0'

dependencies:
  flutter:
    sdk: flutter
  appsdk_v2_flutter_plugin:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
```

You may reference specific branch, tag, or commit hash by specifying the `ref` field.

### 4.3. Plugin usage

Methods and properties made available as public APIs implemented with the `IaSdk` object. 

The client setup requires instantiation of this object for usage: 

```dart
import 'package:flutter/material.dart';
import 'package:appsdk_v2_flutter_plugin/sdk.dart';

void main() {
  final iaSdkConfig = IaSdkConfiguration(
    accessKey: 'myAccessKey',
    clientId: 'myClientId',
    serverEnvironment: 'myServerEnvironment',
  );
  runApp(
    IaSdk( // Alternatively, place the [IaSdk] wrapper somewhere else in the widget tree.
      child: ExampleApp(),
      configuration: ExampleAppConfig.instance.pluginConfig,
    ),
  );
}
```

In the above example, after specifying the required fields with the `IaSdkConfiguration`, 
an `IaSdk` [Widget](https://docs.flutter.dev/get-started/fundamentals/widgets) 
is placed in the widget tree in order to be accessed using any available 
[BuildContext](https://api.flutter.dev/flutter/widgets/BuildContext-class.html) value:

```dart
class _ExampleAppState extends State<ExampleApp> {
  /// Getter method for retrieving of the nearest ancestor object of [IaSdkApi] type.
  /// 
  IaSdkApi? get _iaSdk {
    return IaSdk.of(context);
  }

  /// Allocate the ia.de runtime resources.
  /// 
  Future<void> _initIaSdk() async {
    await _iaSdk?.init();
  }
}
```

Using the specified method, the client implementation is enabled with access to any of the [IaSdkApi] properties,
and may access them from any point in the widget tree.

---

For further information, please see the 
[API reference](https://ihreapotheken.github.io/docs/appsdk/flutter).