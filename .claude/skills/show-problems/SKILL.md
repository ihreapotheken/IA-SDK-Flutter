---
name: show-problems
description: Find problems in the IA SDK Flutter plugin by comparing the Dart side with the native iOS and Android code. Covers argument shapes that don't match, callbacks or events one platform never sends, raw values Dart would reject, missing native handlers, and doc comments that contradict the code. Each problem links to the Dart and native code involved. Use when asked for bugs, mismatches, inconsistencies or problems in the plugin. Writes the result to generated/PROBLEMS.md.
---

# IA SDK Flutter problems

Compare every public Dart API entry with its native iOS and Android counterparts, and report what doesn't line up. Report findings only; don't change any code.

## Output

- Always write to `generated/PROBLEMS.md` at the repo root. Create the folder if needed and overwrite the file.
- Start the file with a title, the generation date, and the current branch and short commit (`git rev-parse --abbrev-ref HEAD`, `git rev-parse --short HEAD`).
- Do not print the findings in chat. Reply with a clickable link to the file, `[generated/PROBLEMS.md](generated/PROBLEMS.md)`, plus one line naming the branch and commit and the number of problems per severity.
- Any argument text narrows the scope, for example `ordering` or `android only`.

## What to read

Always read the current code; never reuse an earlier report. Line numbers change.

- **Dart side:**
  - [lib/src/core.dart](lib/src/core.dart)
  - [lib/src/common/](lib/src/common/) (`methods.dart`, `navigation.dart`, `views.dart`)
  - [lib/src/models/request/](lib/src/models/request/), for the argument maps sent to native
  - `interface/lib/src/modules/*/` (abstract classes, doc comments, models and enums with `rawValue`/`fromRawValue`)
  - `modules/*/lib/src/`: `impl.dart`, `methods.dart`, `views.dart`, `callbacks/`, `models/request/`, `widgets/`
- **iOS core:** in `ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/`
  - routing: `IaSdkPlugin.swift`, `Common/Entities/FlutterCall.swift`
  - argument decoding: `Common/Entities/MethodArguments/`
  - logic: `Features/*/…Wrapper.swift`
  - screens and components: `Features/IASDK/IASDKViewIdentifier.swift`, `Features/IASDK/IASDKComponentsViewFactory.swift`
  - callbacks: `Common/Delegate/IaClientDelegate.swift`
- **Android core:** in `android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/sdk/`
  - routing, argument parsing and screens: `IaClientMethods.kt`
  - callbacks: `IaClientCallbacks.kt`
  - components: `IaClientComponents.kt`
- **Module plugins:**
  - iOS: `modules/<module>/ios/<module>/Sources/<module>/`
  - Android: `modules/<module>/android/src/main/kotlin/de/ihreapotheken/appsdk/flutter/<module>/`
  - Include their event senders and listeners.

## What to check

For each method, screen, widget, callback and stream, trace Dart → native or native → Dart on both platforms, and look for:

1. **Argument shape mismatches.** Keys, types or nesting differ between the Dart request map and what native decodes, or between what native sends and what the Dart handler expects. Examples: native sends a Map but Dart expects a String; `int` vs `String`; missing or renamed keys.
2. **Missing senders.** A callback, stream or event that one platform never sends.
3. **Unknown raw values.** A native side sends a value that `fromRawValue` or a Dart `switch` would reject, or never sends a value that Dart expects.
4. **Missing handlers.** A Dart method with no native handler, `notImplemented`, or an empty body on one platform, where the doc comment doesn't say so.
5. **Doc vs code.** "iOS only" or other platform notes in doc comments that contradict what the native code does.
6. **Identifier mismatches.** `viewId`s, platform view ids or channel names that differ between Dart and native, including the Android capitalisation rule in `IaBaseViews` and `IaSdkPlatformView`.
7. **Error handling that hides failures.** Places where an error is swallowed and silently turned into a default, so the host never finds out. Example: `IaBaseCallbacks` catching a handler exception, so native falls back to its default.
8. **API inconsistencies** (low severity). The same concept typed differently across methods, or a raw JSON/Map return where a model already exists.

Only report what the code shows. Where a finding needs runtime confirmation, say so and suggest how to confirm it, e.g. with a log in the example app.

## Output format

Group the problems by severity:
- **High:** a feature silently doesn't work
- **Medium:** wrong on one platform, or a crash/exception path
- **Low:** misleading docs and inconsistencies

Each problem is one numbered entry:

```
1. **Short title** (iOS / Android / both)
   - What happens: one or two sentences tracing the flow.
   - Evidence: [Dart](…#Lx) · [iOS](…#Ly) · [Android](…#Lz), linking the exact lines involved.
   - Impact: what the host app sees.
   - How to confirm (if runtime confirmation is needed).
```

If a category has no findings, leave it out. If nothing at all is found, say so.

## Links

- Use markdown links with line anchors: `[label](path#L42)` or `[label](path#L42-L51)`. Never use backticks for file references.
- Get line numbers from the current files, e.g. with `grep -n`.
- Prefix every path with `../`, since links resolve from the file's own folder.
- Before replying, check that every link target in the file exists and every `#L` anchor is within its file. Fix any broken link.
