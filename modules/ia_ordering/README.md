# ia_ordering

AppSDK Ordering service.

## Implementation

For AppSDK usage, see the main [README.md](https://ihreapotheken.github.io/docs/appsdk/flutter) file.

API reference: https://ihreapotheken.github.io/docs/appsdk/flutter/sdk/IaBaseOrdering-class.html

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
  ia_ordering:
    git:
      url: https://github.com/ihreapotheken/IA-SDK-Flutter
      ref: main
      path: modules/ia_ordering
```