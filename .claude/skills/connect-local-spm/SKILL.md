---
name: connect-local-spm
description: Connect the IA SDK Flutter plugin's example app to a local IA-SDK-Dev-iOS checkout through Swift Package Manager, so native iOS SDK changes can be debugged in the example app right away, without publishing binaries. Also disconnects it again, or shows which SDK it uses now. Use when asked to debug the plugin against the local iOS SDK, connect or disconnect the local Swift package, or switch back to the released SDK binaries. Local-only debug setup; the changes must never be committed.
---

# Connect the example app to the local iOS SDK (SPM)

Normally the plugin's Swift packages depend on the released binaries:
`.package(url: "https://github.com/ihreapotheken/IA-SDK-iOS", exact: <IOS_APPSDK_VERSION from .env>)`.
This skill points them at a local `IA-SDK-Dev-iOS` checkout instead. Xcode then compiles the SDK from source, so a change in the SDK shows up in the example app on the next build. Native SDK breakpoints work too.

Scope: only the **example app in this repo**. It uses the plugin and all modules through `path:` dependencies, and Flutter symlinks their iOS packages into `example/ios/Flutter/ephemeral/Packages/.packages/`. Patching the repo's `Package.swift` files is therefore all the setup it needs. Core App needs a different setup (it patches the plugin inside `~/.pub-cache`); see `IA-SDK-Dev-iOS/docs/HowToDebugCoreAppOnLocalSPM.md`.

> **Never commit** the patched `Package.swift` files or the rewritten `Package.resolved` files. They contain a path on one machine. Run `restore` before committing anything in this repo.

## Script

Everything mechanical is done by [scripts/ia_local_spm.py](scripts/ia_local_spm.py). Run it from anywhere; it finds the repo from its own location.

| Command | What it does |
|---|---|
| `python3 .claude/skills/connect-local-spm/scripts/ia_local_spm.py apply [SDK path]` | Patches all 6 manifests (see below). Without a path it uses `IA_SDK_IOS_APP_PATH` from `.env.local`. Safe to run again, for example with a different SDK path. Refuses a path whose `Package.swift` isn't the `IASDK` package. |
| `… restore` | Undoes the patch exactly (byte-identical to before), restores both example `Package.resolved` files from git, and runs `clean-noise`. |
| `… status` | Prints `LOCAL <path>` or `remote` for each manifest. |
| `… clean-noise` | Reverts `analysis_options.yaml` files whose only change is the block Flutter adds (see Known issues). |

The manifests it patches are `ios/appsdk_v2_flutter_plugin/Package.swift` and `modules/*/ios/*/Package.swift` (ia_cardlink, ia_ordering, ia_over_the_counter, ia_pharmacy, ia_prescription). In each one:
- `.package(url: ".../IA-SDK-iOS", exact: …)` becomes `.package(name: "IASDK", path: "<SDK>")`. The original line is kept in a trailing `// IA_LOCAL_SPM was:` comment.
- `.product(…, package: "IA-SDK-iOS")` becomes `package: "IASDK"`. `IASDK` is the `name:` in `IA-SDK-Dev-iOS/Package.swift`, which exposes all six products.
- Main plugin only: it adds `path: "Sources/app_sdk_v2_flutter_plugin"`. The target is called `appsdk_v2_flutter_plugin`, but its folder isn't, and SPM looks in `Sources/<target name>` by default. The released-binary build doesn't hit this because it uses CocoaPods.

Every edited line ends with `// IA_LOCAL_SPM`. That marker is how `restore` and `status` find the edits.

## Arguments

`$ARGUMENTS` is free text. Interpret it:
- **A path** (absolute, `~/…`, or relative): connect to that SDK checkout.
- **`restore` / `disconnect` / `remote` / `undo`** (or the same request in other words): disconnect.
- **`status`**: run `status` and report.
- **Empty** (or "connect" with no path): use `IA_SDK_IOS_APP_PATH` from `.env.local` at the repo root. Run `apply` without a path; the script reads it and prints `using IA_SDK_IOS_APP_PATH from .env.local: …`. Mention that path in the report. `.env.local` is gitignored and belongs to each developer; `.env.local.example` is its template.
- **Empty, and `.env.local` or the variable is missing** (the script exits with "apply needs the IA-SDK-Dev-iOS path"): ask for the path. If `../IA-SDK-Dev-iOS/Package.swift` exists next to this repo, use AskUserQuestion: offer that path as the first option, marked (Recommended), and add "Disconnect (restore released binaries)" as a second option. The user can type any other path under "Other". If no sibling checkout exists, ask in plain text and wait. Then suggest copying `.env.local.example` to `.env.local` and setting the path there for next time.

A path the user gives explicitly always overrides `.env.local`.

## Connect

1. **Check prerequisites.**
   - `flutter config --list` must show `enable-swift-package-manager: true`. If it doesn't, ask before running `flutter config --enable-swift-package-manager`, because that setting is global.
   - The SDK path (given explicitly, or `IA_SDK_IOS_APP_PATH` in `.env.local`) must contain `Package.swift` with `name: "IASDK"` (the script checks this).
   - Report the SDK's branch (`git -C <SDK> rev-parse --abbrev-ref HEAD`). The plugin is written against the SDK version in `.env`. If the SDK has moved on, plugin Swift code may not compile; that is for the user to fix.
2. **Patch:** run `python3 .claude/skills/connect-local-spm/scripts/ia_local_spm.py apply [SDK path]`. Leave out the path when the user didn't give one, so `.env.local` is used.
3. **Regenerate Flutter's SPM integration:** run `cd example && flutter pub get`. This rewrites `example/ios/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage` and the `.packages` symlinks.
4. **Build for the simulator.** It doesn't need signing, so it's the quickest check:
   `cd example && flutter build ios --debug --simulator > <scratchpad>/build_sim.log 2>&1; echo "exit $?" >> <scratchpad>/build_sim.log`
   - Run it in the background. The first build resolves the SDK's own packages (OpenSSL-Swift, link4health, ref-OpenHealthCardKit, ASN1Kit, DeviceKit, Commandant) and compiles the whole SDK. That takes a few minutes.
   - Judge success from the log: `✓ Built …` or `Failed to build iOS app`, plus the `exit` line. Don't trust the background task's own exit code; it reported 0 for a failed build.
   - Confirm `example/ios/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved` no longer contains `"identity" : "ia-sdk-ios"`. If it still does, resolution used a stale state; see Troubleshooting.
5. **Clean up:** run `… clean-noise`.
6. **Report:**
   - the `status` output
   - the build result
   - the first compile error, if there was one, with file:line (Flutter only shows the first)
   - a reminder that the change is local-only and that `restore` undoes it

Compile errors in the SDK or plugin sources are the user's to fix unless they ask you to. Errors caused by packaging are different (see Known issues): explain them and propose a fix.

## Debug loop (tell the user)

- **Quick check:** edit SDK code in `IA-SDK-Dev-iOS`, then run `cd example && flutter run` (or `flutter build ios --debug --simulator`). Only the changed SDK targets recompile.
- **Breakpoints in SDK code:** open `example/ios/Runner.xcworkspace` in Xcode. The SDK appears under *Package Dependencies → IASDK* as editable local sources. Set breakpoints there and run the `Runner` scheme. Run `flutter build ios --debug` (or `flutter pub get`) once first, so the generated Flutter files exist.
- **Real device:** use `flutter run -d <device id>`, or Xcode with a signing team set for `Runner`. You need a device for CardLink/NFC. The SPM setup is the same as for the simulator; only signing is extra. Both simulator and device builds were tested on 2026-10-14.

## Disconnect

1. Run `python3 .claude/skills/connect-local-spm/scripts/ia_local_spm.py restore`.
2. Run `cd example && flutter pub get`, then `… clean-noise`.
3. Run `git status --short` and confirm none of the patched files or `Package.resolved` files are still modified. Report this to the user.
4. The next build re-resolves the released `IA-SDK-iOS` binaries.

## Known issues

- **`'retroactive' attribute does not apply; 'X' is declared in the same package`** (SDK source). In the Xcode project build, IACore is a separate module, so `extension Product: @retroactive Identifiable` is correct there. In the SPM build, all SDK targets are one package, so the attribute is an error. Fix it in a way that compiles both ways by qualifying the module names instead: `extension IACore.Product: Swift.Identifiable`. The first occurrence, in `IAOverTheCounter/.../Product+.swift`, was fixed this way in `IA-SDK-Dev-iOS` on 2026-10-14. If this error comes back, check for a new `@retroactive` with `grep -rn "@retroactive" --include="*.swift" <SDK>`.
- **SDK files that aren't in its Xcode project.** SPM compiles every source file under a target's path, while the Xcode project compiles only the files it lists. A leftover file can break only the SPM build. Fix this in the SDK, for example by deleting the file or adding it to `exclude:`.
- **`flutter pub get` / `flutter build` (Flutter 3.47+) edit `analysis_options.yaml` in every package** (root, `interface/`, `modules/*`, `example/`). They append `analyzer: exclude: [build/**, android/**, ios/**]`. This has nothing to do with this skill; `clean-noise` reverts it whenever that block is the only change.
- `example/ios/Podfile.lock` and `Pods/` may still contain old IA pods from CocoaPods builds. Under SPM the IA plugins don't come from them, so ignore them.

## Troubleshooting

- **Old binaries still used, or `Package.resolved` still lists `ia-sdk-ios`:** run `… status` to confirm all manifests are `LOCAL`. Then run `cd example && flutter clean && flutter pub get` and rebuild. If Xcode is open, close it or use *File → Packages → Reset Package Caches*.
- **`apply` says "Expected one IA-SDK-iOS dependency … found 0":** the manifest has changed shape upstream. Read it and adjust the regex in the script.
- **A new module was added:** the `modules/*/ios/*/Package.swift` glob picks it up automatically.
