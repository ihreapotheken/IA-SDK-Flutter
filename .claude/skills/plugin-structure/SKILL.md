---
name: plugin-structure
description: Explain where code lives in the IA SDK Flutter plugin repo (iOS native Swift, Android native Kotlin, Dart interfaces, Dart implementations, example app, versioning, scripts, CI). Use when asked about project structure, "where is X code", or how the repo is laid out.
---

# IA SDK Flutter plugin structure

Give the user a nested-list overview of where code lives in this repo.

## Steps

1. Check the current layout against the reference map below. Paths may have changed, so confirm them before you answer, for example:
   - `ls ios/*/Sources/*` and `ls -d modules/*/ios/*/Sources/*`
   - `find android/src/main/kotlin modules/*/android/src/main/kotlin -mindepth 4 -maxdepth 5 -type d`
   - `ls interface/lib/src/common interface/lib/src/modules lib/src example/lib/src example/lib/src/views scripts .github/workflows`
   - `cat .env`
2. Fix any path in the map that no longer matches, and add any new important folders, such as a new module.
3. Answer with a nested list in the format below. Make every path a clickable markdown link relative to the workspace root. Keep the descriptions short.

## Output format

```
- iOS native
  - path — short description
- Android native
  - ...
- Dart interfaces
  - ...
- Dart implementations
  - ...
- Example project
  - ...
- Other
  - topic: path — short description
```

## Reference map

Native code is split into two parts:
- the **core plugin** at the repo root (`ios/`, `android/`, `lib/`)
- **module plugins** in `modules/<module>/`, where each module is a separate Flutter plugin with its own Dart, Swift and Kotlin code

Modules: `ia_cardlink`, `ia_ordering`, `ia_over_the_counter`, `ia_pharmacy`, `ia_prescription`.

- **iOS native (Swift)**
  - Core: `ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/`
    - `IaSdkFlutter.swift` is the entry point
    - `IaClientBindings.swift` sets up the MethodChannel
    - `IaSdkPlugin.swift` routes method calls
    - `Common/` holds the delegate, entities, argument decoding and error mapping
    - `Features/` holds the wrappers around each native SDK module (`IASDKWrapper`, `IAOrderingWrapper`, …)
  - Modules: `modules/<module>/ios/<module>/Sources/<module>/`, with Events, Methods, Models and Extensions
  - SPM: `ios/appsdk_v2_flutter_plugin/Package.swift`, `modules/<module>/ios/<module>/Package.swift`
  - CocoaPods: `ios/appsdk_v2_flutter_plugin.podspec`, `modules/<module>/ios/<module>.podspec`
- **Android native (Kotlin)**
  - Core: `android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/`
    - `IaSdkFlutter.kt` is the entry point
    - `sdk/` contains `IaClientBindings`, `IaClientMethods`, `IaClientCallbacks` and `IaClientViews`
  - Modules: `modules/<module>/android/src/main/kotlin/de/ihreapotheken/appsdk/flutter/<card_link|ordering|over_the_counter|pharmacy|prescription>/`, with methods, listeners, events and models
  - Gradle: `android/build.gradle`, `modules/<module>/android/build.gradle`
- **Dart interfaces (abstract contracts)**
  - `interface/lib/ia_interface.dart` re-exports everything
  - `interface/lib/src/common/` holds `IaBase`, `IaBaseModule`, `IaBaseMethods`, `IaBaseViews` and `IaBaseCallbacks`
  - `interface/lib/src/modules/<module>/` has one abstract class per module plus shared `models/`
- **Dart implementations**
  - Core: `lib/sdk.dart` is the public export and `lib/src/core.dart` holds the `IaSdk` singleton
    - `lib/src/config/` holds configuration
    - `lib/src/common/` holds methods, navigation and views
    - `lib/src/models/` holds request and response models
  - Modules: `modules/<module>/lib/src/`
    - `impl.dart` is the concrete class
    - `methods.dart` is the `_Methods` enum
    - `views.dart` holds the view definitions
    - `callbacks/` and `models/request/` hold the callback handlers and request models
- **Example project**
  - `example/lib/main.dart` is the entry point and `example/lib/src/app.dart` is the app with tab navigation
  - `example/lib/src/views/` holds the home, cardlink, services, screens and components views
  - `example/lib/src/e2e/` holds e2e code
  - Host apps: `example/ios/` (Runner Xcode project / workspace) and `example/android/`
- **Other**
  - Native SDK versions: `.env` sets `IOS_APPSDK_VERSION` and `ANDROID_APPSDK_VERSION`. `Package.swift`, the podspecs and `build.gradle` all read it.
  - Package definitions: root `pubspec.yaml`, plus a `pubspec.yaml` in `interface/` and in each module
  - Scripts: `scripts/` holds scripts for deploying the client and demo app, dev environment setup, docs generation and `info.sh`
  - CI: `.github/workflows/` holds `demo_app_deploy.yml` and `generate_licenses.yml`
  - Docs: `README.md`, `IMPORTANT.md`, `CHANGELOG.md`, and `licenses/` for third-party licenses
  - Claude instructions: `.claude/CLAUDE.md`
