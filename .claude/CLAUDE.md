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
- It consists of multiple independent binaries (listed below).
- All modules depend on IACore.
- IACore doesn't know about modules and modules don't know about each other. 

## Binaries
- IACore: 
  - reusable UI and non UI components (on iOS some of code is in separate IOSKit module but that is not relevant).
  - some common entities that are used between modules (pharmacy, product etc.)
  - interfaces through which other modules communicate with each other
  - it has no dependencies (doesn't know about any other module)
  - all other modules depend on it
- IAIntegrations:
  - bigger common features used in modules or directly by host app
- IAOverTheCounter:
  - product search
- IAOrdering: 
  - cart and checkout
- IAPharmacy:
  - pharmacy details (basic pharmacy logic is inside IACore because it is needed everywhere).
- IAPrescription:
  - prescription scanner
- IACardLink:
  - CardLink feature (NFC scanning)
  
## Communication between binaries
- Because all modules are delivered as independent binaries, they don’t reference each other directly. Instead, any cross-module communication happens 
through interfaces that live in IACore. If a module needs functionality that is implemented in another module, it calls an interface defined in IACore. 
The concrete implementation of that interface is then supplied by the host app at runtime.

Example (iOS):
If a module wants to display the cart button, it uses the interface exposed by IACore:
`IACore.DICore.sharedSDKModuleProvider.ordering.cartButton`
where sharedSDKModuleProvider.ordering is an interface that is instantiated by host app like this:
```
import IAOrdering
IASDK.register(.ordering)
```

# Dart implementation
- plugin code location: /lib
- demo app location: /example (most of the code is in example/lib/main.dart)
- code structure:
  - modules/ia_sdk.dart
    - Main SDK class (IaSdkWidget wrapper and IaSdk API class)
    - Defines core SDK methods that host app can call (init, register, setPharmacyId, etc.)
    - Each method validates arguments using ArgumentValidator and invokes native via shared IaSdkChannel
    - Contains module properties (e.g., ordering)
  - modules/{module}/
    - Individual module classes (e.g., ia_ordering.dart)
    - Each module is self-contained and invokes native directly via IaSdkChannel
  - common/utilities/
    - ia_sdk_channel.dart: Singleton providing shared MethodChannel
    - argument_validator.dart: Reusable argument validation utility
  - common/callbacks/
    - Callback handlers for native → Dart → host app communication
    
# iOS implementation
- plugin code location: /ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/

# Android implementation
- plugin code location: /android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/sdk/

# Coding tasks for plugin
## General notes
- currently native SDKs are modularized (multiple binaries) but flutter plugin is not.
- even though plugin is not modularized, we want to create similar classes/intefaces as in native so in case we want to modularize it in the future, host 
app developers won't have to change code, e.g. if something in native is defined in IAOrdering (e.g. transferprescriptions) then Dart code should also expose 
it through its IaOrdering class and just proxy the call to native function.
- we want plugin to be just a proxy to native SDK, meaning it should reflect native implementations as much as possible and not add additional functionality.
- when sending something with method channel from dart to native, always use map type for arguments, even if there is only one argument. This is because 
we want to be able to convert arguments to json and then convert that json to swift/kotlin objects.

## How to add dart function that calls native function

All functions follow the same pattern - validate arguments and call the native method directly via IaSdkChannel.

### For module-specific functions (e.g., IaOrdering, IaPharmacy)
1. Add function to appropriate module class in /lib/modules/{module}/ (e.g., ia_ordering.dart)
2. Create arguments map, validate with ArgumentValidator.verify(), invoke via IaSdkChannel
3. Add native implementation

Example:
```dart
Future<void> someFunction({String? param}) async {
  final arguments = {'param': param};
  ArgumentValidator.verify(arguments, argumentType: Map, requiredMapFields: [...]);
  await IaSdkChannel.instance.channel.invokeMethod('someFunction', arguments);
}
```

### For core SDK functions (non-module specific)
1. Add function to IaSdk class in /lib/modules/ia_sdk.dart
2. Create arguments map, validate with ArgumentValidator.verify(), invoke via _channel (which uses IaSdkChannel)
3. Add native implementation

Example (same pattern as modules):
```dart
Future<void> someFunction({String? param}) async {
  final arguments = {'param': param};
  ArgumentValidator.verify(arguments, argumentType: Map, requiredMapFields: [...]);
  await _channel.invokeMethod('someFunction', arguments);
}
```

Native implementation:
- iOS: /ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/IaClientMethods.swift
- Android: /android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/sdk/IaClientMethods.kt

## How to add callback (native → Dart → host app)
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
