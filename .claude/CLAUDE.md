References:
- iOS IA SDK: https://github.com/ihreapotheken/IA-SDK-iOS
- Android IA SDK: https://github.com/ihreapotheken/IA-SDK-Android
- General Flutter packages docs: https://docs.flutter.dev/packages-and-plugins/developing-packages
- General Flutter platform channels docs: https://docs.flutter.dev/platform-integration/platform-channels

This is IA SDK flutter plugin workspace that consists of:
- dart code that defines interfaces and calls native iOS/Android code
- iOS code that calls iOS IA SDK (see reference above)
- Android code that calls Android IA SDK (see reference above)

# Native IA SDK high level overview
- prerequisites: at start users must select their pharmacy, this is mandatory. Also users can be presented with onboarding flow and legal documents
- pharmacy product search: Users can type in query for pharmacy product, see product details and add them to cart
- ordering: Users can add products and prescriptions to cart, after which they can proceed to checkout process
- pharmacy: Users can see pharmacy details, change pharmacy (Apofinder feature)
- prescriptions: Users can add prescriptions to cart by:
  - scanning qr code
  - taking photo of prescription
  - CardLink (nfc data transfer).

# Native IA SDK technical overview
- Native SDK consists of multiple independent modules (binaries) (listed below).
- All modules depend on IACore.
- IACore doesn't know about modules and modules don't know about each other. 
- Because all modules are delivered as independent binaries, they don’t reference each other directly. Instead, any cross-module communication happens 
through interfaces that live in IACore. If a module needs functionality that is implemented in another module, it calls an interface defined in IACore. 
The concrete implementation of that interface is then supplied by the host app at runtime via register function, e.g. IASDK.register(.ordering).

## Modules (binaries)
- IACore: reusable UI and non UI components, entities, interfaces, it has no dependencies (doesn't know about any other module)
- IAIntegrations: bigger common features used in modules or directly by host app
- IAOverTheCounter: product search
- IAOrdering: cart and checkout
- IAPharmacy: pharmacy details (basic pharmacy logic is inside IACore because it is needed everywhere).
- IAPrescription: prescription scanner
- IACardLink: CardLink feature (NFC scanning)

# Dart implementation
- plugin code location: /lib
- demo app location: /example (most of the code is in example/lib/main.dart)
- code structure:
  - common/callback: manager and handlers for incoming communication: native (some event in SDK happens) → Dart → host app (receives event and returns value) -> Dart -> native (native gets returned value from host app)
  - common/entities: entitites that don't belong to any specific module
  - common/utilities: 
    - ia_sdk_channel.dart: Singleton providing shared MethodChannel that is used for communicating with native code (one channel for everything)
    - argument_validator.dart: Reusable argument validation utility
  - features/ia_sdk
    - IaSdk.dart: Main SDK class (IaSdkWidget wrapper and IaSdk class). Mirror of native IASDK plus some additional fluter stuff.
    - IaSdkPlatformViewLauncher: Represents SDK views, defines identifiers etc.
  - features/{module}: code for specific module, e.g. everything related to IAOrdering goes to features/ia_ordering.

# iOS implementation
- plugin code location: /ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/
- code structure:
  - IaSdkFlutter/IaClientBindings: Flutter plugin setup code. Setups IASDKPlugin.
  - IASDKPlugin: Receives events from method channel and proxies it to correct module (Features/{module}).
  - Features/{module}: code for specific module, e.g. everything related to IAOrdering goes to Features/IAOrdering.
  - Features/IASDK: Mirror of SDK's IASDK features
  - Common/Delegate: Handles IADelegate and communicates with dart code using method channel (see callbacks on dart side).
  - Common/Entities: entitites that don't belong to any specific module
  - Common/Utilities:
    - Error+.swift: Error codes and FlutterError conversion
    - IaArgumentDecoder: Used to decode dictionaries, that we get from method channel, into Swift objects
  
# Android implementation
- plugin code location: /android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/sdk/

# Coding tasks for plugin
## General notes
- currently native SDKs are modularized (multiple binaries) but flutter plugin is not.
- even though plugin is not modularized, we want to create similar classes/intefaces as in native so in case we want to modularize it in the future, host 
app developers won't have to change code, e.g. if something in native is defined in IAOrdering (e.g. transferprescriptions) then Dart code should also expose 
it through its IaOrdering class and just proxy the call to native function.
- we want plugin to be just a proxy/mirror to native SDK, meaning it should reflect native implementations as much as possible and not add additional functionality.
- when sending something with method channel from dart to native, always use map type for arguments, even if there is only one argument. This is because 
we want to be able to convert arguments to json and then convert that json to swift/kotlin objects.

## How to proxy SDK function through plugin
@TODO Android
Example: SDK has IAOrdering.transferPrescriptions function, we want to enable flutter host app to call it.

1. As input to this task, you should be given native SDK signature of the function and in which module it is located. If something is unclear or missing, please ask.
Example: IAOrdering.transferPrescriptions
```
public static func transferPrescriptions(
    images: [Data]? = nil,
    pdfs: [PDFPrescription]? = nil,
    codes: [String]? = nil,
    orderID: String?,
) async throws
```
2. Locate dart module and class in which you have to add that function: /lib/features/{module}/{module.dart}/. In this case /lib/features/ia_ordering/ia_ordering.dart.
3. Add function to that class, mirroring the native arguments (IaOrdering.transferPrescriptions).
4. In that dart function, use ArgumentValidator to validate arguments.
5. Invoke method on IaSdkChannel.instance.channel to pass the call to native code.
Native (iOS):
6. In native plugin code add enum case to FlutterCall enum. In this case we add transferPrescriptions case.
7. Add function to appropriate class, code for ordering module goes to /Features/IAOrdering/IAOrderingWrapper.swift. So add transferPrescriptions function there.
8. In IASDKPlugin, handle FlutterCall.transferPrescriptions case and call IAOrderingWrapper.transferPrescriptions (iOS).
Native (android):
6. @TODO add steps

## How to proxy SDK view through plugin
@TODO Android
Example: SDK has cart screen, we want to enable flutter host app to show it.

1. Locate features/ia_sdk/ia_sdk_platform_view_launcher.dart and add const to IaSdkPlatformView and IaSdkPlatformViewLauncher (example: IaSdkPlatformView.cartScreen, IaSdkPlatformViewLauncher.cartScreen).
2. Add function to launch the screen to IaSdkPlatformViewLauncher (example: IaSdkPlatformViewLauncher.launchCartScreen).
3. Expose launch function in appropriate module class in features/{module}/ (example: IaOrdering.launchCartScreen calls IaSdkPlatformViewLauncher.launchCartScreen).
4. 
- iOS: add case to Features/IASDK/IASDKViewIdentifier.swift and handle it in IASDKViewIdentifier.iaScreen function.
- Android: @TODO add steps
5. Add button in example app (main.dart) that launches this view. 

## How to proxy callback through plugin (native → Dart → host app)
### How it works?
1. Swift/Kotlin: Native plugin code listens to SDK and passes events to plugin via method channel.
IaClientDelegate.sdkShouldOverrideRoute: sends event (sdkWillNavigateToTarget) with method channel
2. Dart: IaSdk listens for method channel and routes it to IaSdkCallbackManager
3. Dart: IaSdkCallbackManager maps call to appropriate handler (SdkWillNavigateToTargetCallbackHandler)
4. Dart: SdkWillNavigateToTargetCallbackHandler calls iaSdk?.callbacks.onSdkWillNavigateToTarget that is set by host app.

### What is where
- **IaClientDelegate.swift**: native plugin code (iOS)
- **lib/modules/ia_sdk.dart**: IaSdk listens to method channel and routes callbacks via IaSdkCallbackManager
- **lib/common/callbacks/ia_sdk_callback_manager**: Routes method channel to appropriate callback handler
- **IaSdkCallbacks**: Class with list of all callbacks that host app can set. Example: iaSdk?.callbacks.onSdkWillNavigateToTarget = ...
- **lib/common/entities/**: Supporting types and enums used by callbacks
- **lib/common/callbacks/**: Individual callback handler classes (one per callback)

### Steps
1. Create a new handler class in lib/common/callbacks/ (example: SdkWillNavigateToTargetCallbackHandler).
2. Supporting types/enums for callbacks should be added to lib/common/entities/. Use "rawValue" and "fromRawValue" for mapping strings to enums. (Example: IaSdkNavigationTarget)
   Note: Try to use same names for entitites and properties as they are in native code (if unclear whether to use iOS or android namings then ask).
3. Add variable to your handler in IaSdkCallbacks. This is set by host app. (example: onSdkWillNavigateToTarget).
4. In _IaPlatformCallbacks.handle() switch statement, instantiate your handler and call its handle() method
5. Implement iOS side in IaClientDelegate class in IaClientBindings.swift
6. Implement Android side (@TODO instructions on how to do that).
7. Update example/lib/main.dart if needed.

### Important
- Callbacks are optional (nullable) - provide sensible defaults if not set
- Use `Future<T>` for callbacks that need responses, `void` for fire-and-forget
