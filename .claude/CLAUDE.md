References:
- iOS IA SDK: https://github.com/ihreapotheken/IA-SDK-iOS
- Android IA SDK: https://github.com/ihreapotheken/IA-SDK-Android
- General Flutter packages docs: https://docs.flutter.dev/packages-and-plugins/developing-packages
- General Flutter platform channels docs: https://docs.flutter.dev/platform-integration/platform-channels

This is IA SDK flutter plugin workspace that consists of:
- dart code that defines interfaces and calls native iOS/Android code
- iOS code that calls iOS IA SDK (see reference above)
- Android code that calls Android IA SDK (see reference above)

# IA SDK high level overview
- prerequisites: at start users must select their pharmacy, this is mandatory. Also users can be presented with onboarding flow and legal documents
- pharmacy product search: Users can type in query for pharmacy product, see product details and add them to cart
- ordering: Users can add products and prescriptions to cart, after which they can proceed to checkout process
- pharmacy: Users can see pharmacy details, change pharmacy (Apofinder feature)
- prescriptions: Users can add prescriptions to cart by:
  - scanning qr code
  - taking photo of prescription
  - CardLink (nfc data transfer).
  
# Dart implementation
- plugin code location: /lib
- demo app location: /example (most of the code is in example/lib/main.dart)
- code structure:
  - sdk.dart
    - Defines methods that host app can call
    - Calls methods.dart where calls are validated and sent to native side
  - methods.dart
    - Enum that lists all methods that dart code can send to native, this enum is used internally from sdk.dart
    - validates arguments that are sent from dart to sdk.dart
    - sends raw method name and arguments to native code using MethodChannel
  - callbacks.dart
    - Used when native needs to send event to host app
    
# iOS implementation
- plugin code location: /ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/

# Android implementation
- plugin code location: /android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/sdk/

# Coding tasks
## How to add dart function that calls native function
1. Define function in sdk.dart, this is what host app will call.
2. Add enum case and implementation to methods.dart. If you need to create dart entities, put it in config.dart.
3. Add native function:
  - iOS: /ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/IaClientMethods.swift
  - Android: /android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/sdk/IaClientMethods.kt

## How to add SDK callbacks (native → Dart → host app)
When adding delegate/callback functions from iOS SDKDelegate or Android callbacks:

### What is where
- **IaSdkCallbacks**: Class with list of all callbacks that host app can set. Example: iaSdk?.callbacks.onShouldOverrideRoute = ...
- **lib/common/entities/**: Supporting types and enums used by callbacks
- **lib/common/callbacks/**: Individual callback handler classes (one per callback)

### Steps
1. Create a new handler class in lib/common/callbacks/ (example: ShouldOverrideRouteCallbackHandler).
2. Supporting types/enums for callbacks should be added to lib/common/entities/. Use "rawValue" and "fromRawValue" for mapping strings to enums. (Example: IaRouteOverride)
3. Add variable to your handler in IaSdkCallbacks. This is set by host app. (example: onShouldOverrideRoute).
4. In _IaPlatformCallbacks.handle() switch statement, instantiate your handler and call its handle() method
5. Implement iOS side in IaClientDelegate class in IaClientBindings.swift
6. Implement Android side (@TODO instructions on how to do that).
7. Update example/lib/main.dart if needed.

### Important
- Callbacks are optional (nullable) - provide sensible defaults if not set
- Use `Future<T>` for callbacks that need responses, `void` for fire-and-forget
