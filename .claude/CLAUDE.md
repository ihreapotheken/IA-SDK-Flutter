This is a IA SDK flutter plugin workspace that consists of:
- dart code that defines interfaces and calls native iOS/Android code
- iOS code that calls iOS IA SDK (https://github.com/ihreapotheken/IA-SDK-iOS)
- Android code that calls Android IA SDK (https://github.com/ihreapotheken/IA-SDK-Android)

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
- location: lib
- code structure:
  - callbacks.dart: Used when native needs to send event to host app
  - methods.dart: Enum that lists all methods that dart code can send to native
  - sdk.dart: This is where dart code communicates with native code using MethodChannel

# iOS implementation
- location: ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/

# Android implementation
- location: android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/sdk/
