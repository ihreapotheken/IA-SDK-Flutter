# ia_prescription

AppSDK Prescription service.

## Implementation

For AppSDK usage, see the main [README.md](https://ihreapotheken.github.io/docs/appsdk/flutter) file.

API reference: https://ihreapotheken.github.io/docs/appsdk/flutter/sdk/IaBasePrescription-class.html

Usage: 

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
  ia_prescription:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
      path: modules/ia_prescription
```

The module should be instantiated, after which it must be forwarded to the `IaSdk.register` method for runtime configuration:

```dart
final iaPrescriptionModule = IaModulePrescription();

Future<void> registerIaModules() async {
  await IaSdk.register(
    modules: [
      iaPrescriptionModule,

      // Other modules.

    ],
  );
}
```