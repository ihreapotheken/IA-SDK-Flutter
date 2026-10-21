---
name: show-public-api
description: List the public Dart API of the IA SDK Flutter plugin (IaSdk core and every module) with parameters, defaults, models and enums, plus links to the Dart declaration and to the iOS and Android native handlers for each method, callback, stream and widget. Use when asked about the plugin's public API, method signatures, or where a Dart call is handled natively. Writes the result to generated/PUBLIC_API.md.
---

# IA SDK Flutter public API

Produce a module-by-module listing of the public Dart API. Each entry links to its Dart declaration and to the native code that handles it on each platform.

## Output

- Always write the listing to `generated/PUBLIC_API.md` at the repo root. Create the folder if needed and overwrite the file.
- Do not print the listing in chat. Reply with a clickable link to the file, `[generated/PUBLIC_API.md](generated/PUBLIC_API.md)`, plus one line naming the branch and commit and the number of methods, callbacks/streams and widgets listed.
- Any argument text narrows the scope, for example `ordering` or `cardlink only`.

## What to read

Always read the current code; never reuse an earlier listing. Line numbers change.

**Public Dart API**
- Core:
  - [lib/sdk.dart](lib/sdk.dart) holds the public exports
  - [lib/src/core.dart](lib/src/core.dart) holds `IaSdk`: getters, methods and callback properties
  - [lib/src/config/](lib/src/config/) holds the configuration models and enums
  - [lib/src/common/navigation.dart](lib/src/common/navigation.dart) holds the callback handlers and `IaSdkNavigationTarget`
- Module interfaces:
  - `interface/lib/src/modules/<module>/<module>.dart` holds the abstract class
  - `interface/lib/src/modules/<module>/models/` holds the module's models and enums
- Module implementations: `modules/<module>/lib/src/`
  - `impl.dart`
  - `methods.dart`, which gives the channel and method ids
  - `views.dart`, which gives the `viewId`s
  - `callbacks/`
  - `widgets/`
- `modules/*/lib/*.dart` shows what each module package exports

**Native handlers**
- Channels:
  - The core channel is `de.ihreapotheken/sdk`, used by `IaSdk` and every module unless `methods.dart` overrides `channel`.
  - CardLink uses `de.ihreapotheken/sdk/cardLink`.
  - Each module's own channel (`de.ihreapotheken/sdk/<module>`) normally handles only `register`.
- iOS core:
  - routing: `ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/IaSdkPlugin.swift`
  - logic: `Features/*/…Wrapper.swift`
  - screens: `Features/IASDK/IASDKViewIdentifier.swift`
  - components: `Features/IASDK/IASDKComponentsViewFactory.swift`
  - callbacks: `Common/Delegate/IaClientDelegate.swift`
- Android core: in `android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/sdk/`
  - routing and logic: `IaClientMethods.kt` (screens via the `launchRoute` branch)
  - components: `IaClientComponents.kt`
  - callbacks: `IaClientCallbacks.kt`
- Module plugins:
  - iOS: `modules/<module>/ios/<module>/Sources/<module>/` (plugin class, `Methods/`, `Events/`)
  - Android: `modules/<module>/android/src/main/kotlin/de/ihreapotheken/appsdk/flutter/<module>/` (plugin class, `methods/`, `events/`, `listeners/`)

Find the native handler by searching for the method id string, e.g. `grep -rn '"getPharmacyId"\|\.getPharmacyId\b'`. If a platform has no handler, or answers `notImplemented`, or does nothing, say so in the entry.

## Output format

Group by module: `1. Core – IaSdk.instance`, then CardLink, Ordering, Over the Counter, Pharmacy, Prescription, and any new module. Leave out internal plumbing that host apps don't use (`IaBase`, `IaBaseModule`, `IaBaseMethods`, `IaBaseViews`, `IaBaseCallbacks`, `IaBaseCallbackHandler`, `IaBaseRequest`, `IaSdkPlatformView`).

Start with a short note on how to read the entries. Then give each module this header line: interface class, package, a link to the impl class, its channel, and links to its native plugin classes. Then add these subsections where they apply:

- **Methods**: one bullet per method:
  ```
  - **`methodName`** → `ReturnType` (iOS only, if applicable)
    - `param: Type` (required / default `x` / platform note)
    - short note if needed (native method name if different, `viewId` for screens)
    - [Dart](…#Lx) · [iOS](…#Ly) · [Android](…#Lz)
  ```
- **Callbacks** (core) / **Streams** (modules): the type, the native method name, and links to the Dart property, the Dart handler, the iOS sender and the Android sender.
- **Widgets**: constructor parameters, the platform view id, and links to the Dart widget and the native component on each platform.
- **Models**: link the class name. Give each field's type, `required` or `?`, and default.
- **Enums**: link the enum name and list its values.

Don't add a section on mismatches or bugs; the `show-problems` skill covers those. Platform facts belong in the entries themselves, e.g. "notImplemented on Android".

## Links

- Use markdown links with line anchors: `[label](path#L42)` or `[label](path#L42-L51)`. Never use backticks for file references.
- Get line numbers from the current files, e.g. with `grep -n`.
- Prefix every path with `../`, since links resolve from the file's own folder.
- Start the file with a title, the generation date, and the current branch and short commit (`git rev-parse --abbrev-ref HEAD`, `git rev-parse --short HEAD`).
- Before replying, check that every link target in the file exists and every `#L` anchor is within its file. Fix any broken link.
