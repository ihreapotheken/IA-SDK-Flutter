References:
- iOS IA SDK: https://github.com/ihreapotheken/IA-SDK-iOS
- Android IA SDK: https://github.com/ihreapotheken/IA-SDK-Android
- General Flutter packages docs: https://docs.flutter.dev/packages-and-plugins/developing-packages
- General Flutter platform channels docs: https://docs.flutter.dev/platform-integration/platform-channels

This is IA SDK Flutter plugin workspace that consists of:
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
- Because all modules are delivered as independent binaries, they don't reference each other directly. Instead, any cross-module communication happens
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

# Project Structure Overview

The Flutter plugin is now **modularized** to mirror the native SDK architecture:

```
/
├── lib/                    # Core SDK implementation
├── interface/              # Abstract interface definitions (shared contracts)
├── modules/                # Individual module implementations
│   ├── ia_cardlink/
│   ├── ia_ordering/
│   ├── ia_over_the_counter/
│   ├── ia_pharmacy/
│   └── ia_prescription/
├── ios/                    # iOS native plugin implementation
├── android/                # Android native plugin implementation
└── example/                # Demo application
```

# Interface Layer (`/interface`)

The interface package defines abstract base classes that all implementations must follow.

## Location: `/interface/lib/src/`

### Common (`/interface/lib/src/common/`)
- **`_interface.dart`** - Core exports and base classes:
  - `IaBase` - Base class for all modules, handles registration
  - `IaBaseModule` enum - Defines available modules: integrations, overTheCounter, ordering, apofinder, pharmacyDetails, prescription, cardLink
  - `IaBaseMethods` - Mixin for native method invocation via MethodChannel
  - `IaBaseViews` - Mixin for launching native UI screens
  - `IaBaseCallbacks` - Handler system for native→Dart→host callbacks
  - `IaBaseCallbackHandler` - Individual callback handler interface
- **`methods.dart`** - Method definition patterns (uses `IaBaseMethods` mixin)
- **`views.dart`** - View/Screen definition patterns with platform-specific widget wrappers
- **`callbacks.dart`** - Callback routing and handler mechanism
- **`modules.dart`** - `IaBaseModule` enum and related definitions
- **`request.dart`** - Request model interface

### Module Interfaces (`/interface/lib/src/modules/`)
Each native module has a corresponding abstract class:
- **`cardlink/cardlink.dart`** - `IaBaseCardLink` abstract class defining CardLink methods (launch, getVersion, getEnvironment, getSavedCards, deleteCard, etc.) and stream listeners
- **`ordering/ordering.dart`** - `IaBaseOrdering` abstract class defining Ordering methods (transferPrescriptions, clearCart, launchCartScreen) and cart/order listeners
- **`over_the_counter/over_the_counter.dart`** - `IaBaseOverTheCounter` abstract class
- **`pharmacy/pharmacy.dart`** - `IaBasePharmacy` abstract class
- **`prescription/prescription.dart`** - `IaBasePrescription` abstract class

### Models (`/interface/lib/src/modules/{module}/models/`)
Shared model definitions used across implementations:
- CardLink models: FlowType, ConsentStatus, Environment, SavedCard, Session, Event enums
- Ordering models: CartState, TransactionSignatures

# Core SDK Implementation (`/lib`)

## Main Entry Point: `/lib/src/core.dart`
`IaSdk` class - Singleton pattern with:
- Getters for each module: `cardLink`, `ordering`, `pharmacy`, etc.
- Methods: `register()`, `initialize()`, `setGuestUserData()`, `logout()`, `launchStartRoute()`, `finishAllActivities()`
- Callback handler: `onSdkWillNavigateToTarget` - allows host app to intercept navigation

## Configuration (`/lib/src/config/`)
- **`_config.dart`** - `IaSdkConfiguration` with accessKey, clientId, serverEnvironment, footer, initialization options
- **`initialization.dart`** - `IaSdkConfigurationInitialization`
- **`footer.dart`** - `IaSdkConfigurationFooter`
- **`server_environment.dart`** - Environment enum (development, staging, production)

## Common (`/lib/src/common/`)
- **`methods.dart`** - `_Methods` enum for SDK-level method calls (register, initialize, setGuestUserData, logout, etc.)
- **`navigation.dart`** - `_NavigationHandler` for callback routing, `IaSdkNavigationTarget` enum, `_NavigationHandlingDecision` enum
- **`views.dart`** - View definitions for screens

## Models (`/lib/src/models/request/`)
Request models sent to native code: `RegisterModules`, `InitConfig`, `GuestUserData`, etc.

# Modular Architecture (`/modules`)

Each module is a **separate Flutter plugin package** with its own native implementations.

## Module Structure Pattern
Example for `/modules/ia_cardlink/`:
```
ia_cardlink/
├── lib/
│   ├── ia_cardlink.dart          # Exports impl.dart
│   └── src/
│       ├── impl.dart             # IaModuleCardLink (extends IaBaseCardLink)
│       ├── methods.dart          # _Methods enum for this module
│       ├── views.dart            # View definitions
│       ├── callbacks/            # Callback handlers
│       │   ├── _callbacks.dart
│       │   ├── consent_event.dart
│       │   ├── session_created.dart
│       │   ├── event.dart
│       │   ├── analytics_event.dart
│       │   └── prescriptions_redeemed.dart
│       └── models/request/       # Request models
│           ├── launch.dart
│           ├── get_saved_cards.dart
│           └── delete_card.dart
├── android/
│   └── src/main/kotlin/de/ihreapotheken/appsdk/flutter/card_link/
│       ├── IaSdkFlutterCardLink.kt   # Main Android plugin class
│       ├── methods/                   # Method handlers
│       ├── listeners/                 # Event listeners
│       ├── events/                    # Event sending logic
│       └── models/                    # Data mappers
├── ios/
│   └── ia_cardlink/Sources/ia_cardlink/
│       ├── IaSdkFlutterCardLink.swift
│       ├── Events/
│       ├── Extensions/
│       ├── Methods/
│       └── Models/
└── pubspec.yaml                  # Registers Flutter plugin
```

## Available Modules
1. **ia_cardlink** - NFC CardLink prescription transfer
2. **ia_ordering** - Cart and checkout functionality
3. **ia_over_the_counter** - Product search and OTC items
4. **ia_pharmacy** - Pharmacy details and selection
5. **ia_prescription** - Prescription scanning

## Key Implementation Pattern
Each module's `impl.dart`:
- Extends base interface (e.g., `IaModuleCardLink extends IaBaseCardLink`)
- Defines custom `MethodChannel` with module-specific channel ID (e.g., `"de.ihreapotheken/sdk/cardLink"`)
- Implements stream listeners for events using `StreamController<T>`
- Implements callbacks property

# iOS Implementation

## Location: `/ios/appsdk_v2_flutter_plugin/Sources/app_sdk_v2_flutter_plugin/`

### Plugin Setup
- **`IaSdkFlutter.swift`** - Entry point, minimal setup
- **`IaClientBindings.swift`** - Initializes MethodChannel, registers platform view factory
- **`IaSdkPlugin.swift`** - Routes method calls to appropriate wrappers based on `FlutterCall` enum

### Common Components (`/Common/`)
- **`Delegate/IaClientDelegate.swift`** - Implements native SDK callbacks:
  - `sdkWillNavigateToTarget()` - Navigation interception
  - `orderingDidFinishOrders()` - Order completion
  - `orderingDidUpdateCart()` - Cart updates
  - Sends data back to Dart via MethodChannel

- **`Entities/`**
  - `FlutterCall.swift` - Enum of available methods (register, initialize, setPharmacyId, clearCart, setGuestUserData, logout, launchRoute, transferPrescriptions, finishAllActivities)
  - `MethodArguments/` - Decodable argument types (IaInitSdkArguments, IaRegisterModulesArguments, etc.)
  - `IaArgumentError.swift` - Custom error type

- **`Utilities/`**
  - `Error+.swift` - Error mapping to FlutterError
  - `IaArgumentDecoder.swift` - Decodes dictionaries from method channel into Swift objects

### Feature Wrappers (`/Features/`)
Each module has a wrapper translating Dart calls to native SDK calls:
- **`IASDKWrapper.swift`** - SDK initialization, registration, pharmacy selection, guest data
- **`IAOrderingWrapper.swift`** - Cart operations
- **`IACardLinkWrapper.swift`** - CardLink operations
- **`IAPrescriptionWrapper.swift`** - Prescription operations
- **`IAPharmacyWrapper.swift`** - Pharmacy operations
- **`IAOverTheCounterWrapper.swift`** - Product search operations
- **`IAIntegrationsWrapper.swift`** - Integrations module

### View Factory
- **`IASDKViewFactory.swift`** - Creates platform views for SDK screens
- **`IASDKViewIdentifier.swift`** - Maps view identifiers to actual screens

### Module-Specific iOS Code
Each module in `/modules/{module}/ios/` contains:
- Main plugin class (e.g., `IaSdkFlutterCardLink.swift`)
- `Events/` - Event sending to Dart
- `Methods/` - Method handling
- `Models/` - Data conversion/mapping
- `Extensions/` - Swift extensions

# CocoaPods Support

The Flutter plugin supports both Swift Package Manager (SPM) and CocoaPods for iOS dependency management.

## For Plugin Developers

### Dynamic Version Management
All podspec files automatically read `IOS_APPSDK_VERSION` from `.env` at evaluation time, just like `Package.swift` files do for SPM. This ensures:
- **Automatic synchronization**: No manual script needed when updating `.env`
- **Single source of truth**: `.env` file controls versions for both SPM and CocoaPods
- **Consistency**: Both build systems always use the same version

When you update `IOS_APPSDK_VERSION` in `.env`, the podspecs automatically use the new version on next `pod install` or `pod update`.

### How It Works
Each podspec includes Ruby code that:
1. Reads the `.env` file from the project root
2. Extracts `IOS_APPSDK_VERSION`
3. Uses that version for all IA-SDK-iOS dependencies

Example from podspec:
```ruby
# Read IOS_APPSDK_VERSION from .env file
def read_env_version(podspec_dir)
  env_file = File.join(podspec_dir, '..', '..', '.env')
  # ... parsing logic ...
end

ios_appsdk_version = read_env_version(__dir__)

Pod::Spec.new do |s|
  # ...
  s.dependency 'IAIntegrations', ios_appsdk_version
end
```

### Validating Podspecs
To validate podspecs:

```bash
pod lib lint <podspec_name>.podspec --allow-warnings \
  --sources='https://cdn.cocoapods.org/,https://github.com/ihreapotheken/IA-SDK-iOS/'
```

### Podspec Files
- Main plugin: `ios/appsdk_v2_flutter_plugin.podspec`
- Module plugins: `modules/{module}/ios/{module}.podspec`

Each podspec declares dependencies on:
- `Flutter` framework
- `IAIntegrations` (IA-SDK-iOS common module)
- Module-specific IA-SDK-iOS framework (for module plugins only)

All IA-SDK-iOS dependencies dynamically read their version from `.env`.

## For Host App Developers

### Using the Plugin with CocoaPods

1. Add both CocoaPods sources to your Podfile:
```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/ihreapotheken/IA-SDK-iOS/'
```

2. Add the plugin dependencies as usual:
```ruby
# In your Podfile, Flutter handles plugin dependencies automatically
# Just ensure you have the correct sources declared at the top of the file
```

3. Install pods:
```bash
pod install
```

### Requirements
- iOS 15.0 or higher
- Swift 5.9 or higher
- Access to the private IA-SDK-iOS repository on GitHub

### Troubleshooting

**Issue:** Cannot find IA-SDK-iOS pods

**Solution:** Ensure both sources are declared in your Podfile and you have access to the private repository

**Issue:** Version mismatch errors

**Solution:** Run `pod repo update` to fetch the latest specs, then `pod install`

**Issue:** Swift version conflicts

**Solution:** Ensure your project uses Swift 5.9 or higher

**Issue:** Error reading .env file

**Solution:** Ensure `.env` file exists at project root and contains `IOS_APPSDK_VERSION`

## Version Management Workflow

### Updating Versions
1. Update `IOS_APPSDK_VERSION` in `.env`
2. Run `pod install` or `pod update` (podspecs automatically read new version)
3. Commit your changes

That's it! No sync scripts needed.

### Podspec Maintenance
All podspecs dynamically read from `.env` at evaluation time. The version is never hardcoded in podspec files - it's always read from `.env`, ensuring both SPM and CocoaPods use the same version.

## Architecture Notes

### Dependency Structure
```
Main Plugin Podspec:
- IAIntegrations @ IOS_APPSDK_VERSION (from .env)

Module Plugin Podspecs:
- IAIntegrations @ IOS_APPSDK_VERSION (from .env)
- Module-specific framework @ IOS_APPSDK_VERSION (from .env)
  (e.g., IACardLink, IAOrdering, IAPharmacy, etc.)
```

### Version Pinning Strategy
- Uses exact version matching (e.g., `'1.0.0-beta.4'`)
- Mirrors SPM behavior for consistency
- Prevents unexpected version changes during pod install
- Version is always read from `.env` file dynamically

### Private Spec Repository
- IA-SDK-iOS pods are hosted in a private GitHub repository
- Both public CocoaPods CDN and private repo must be specified in Podfile
- Developers need repository access for pod resolution

### Comparison with SPM
Both SPM and CocoaPods now work identically:
- **SPM**: `Package.swift` reads `.env` at build time
- **CocoaPods**: Podspecs read `.env` at pod install/update time
- Both always use the same version from `.env`
- No manual synchronization needed

# Android Implementation

## Core Plugin: `/android/src/main/kotlin/de/ihreapotheken/appsdk_v2_flutter_plugin/`

### Plugin Setup
- **`IaSdkFlutter.kt`** - FlutterPlugin entry point, handles activity lifecycle
- **`sdk/IaClientBindings.kt`** - Initializes MethodChannel, sets up method handler, registers platform view factory

### Method Call Routing
- **`IaClientMethods.kt`** - Routes method calls via `FlutterCall` enum:
  - Methods: register, initialize, setPharmacyId, clearCart, setGuestUserData, logout, launchRoute, transferPrescriptions, finishAllActivities
  - Parses arguments (expects Map type for arguments)
  - Builds configuration and initializes SDK

### Callback Handling
- **`IaClientCallbacks.kt`** - Implements CartListener and CheckoutListener:
  - `handleNavigationTarget()` - Async navigation interception using suspend coroutines
  - `onCartChanged()` - Cart update notifications
  - `onCheckoutFinished()` - Order completion
  - Sends data back to Dart via MethodChannel

### View Handling
- **`IaClientViews.kt`** - Platform view factory and screen launching

### Module-Specific Android Code
Each module in `/modules/{module}/android/` contains:
- Main plugin class (e.g., `IaSdkFlutterCardLink.kt`)
- `methods/` - Method handlers
- `listeners/` - Event listeners
- `events/` - Event sending logic
- `models/` - Data mappers

# Example App (`/example`)

## Location: `/example/lib/`

### Structure
- **`main.dart`** - Entry point, loads environment variables
- **`src/app.dart`** - `ExampleApp` widget with bottom navigation (4 tabs)
  - Tab 0: HomeView (Host app demo)
  - Tab 1: CardLinkView (CardLink demo)
  - Tab 2: ServicesView (SDK services)
  - Tab 3: ScreensView (SDK screens)

### Views (`/example/lib/src/views/`)
- **`home_view.dart`** - SDK initialization and basic operations
- **`cardlink_view.dart`** - CardLink functionality demo
- **`services_view.dart`** - Available services
- **`screens_view.dart`** - Available screens to launch

### Services (`/example/lib/src/services/`)
- **`sdk_initializer.dart`** - SDK initialization logic

# Communication Patterns

## Method Call Flow (Dart → Native)
```
Dart Module (impl.dart)
  └─> _Methods enum (methods.dart)
      └─> invoke() [via IaBaseMethods mixin]
          └─> MethodChannel.invokeMethod(methodId, args)
              └─ iOS: IaSdkPlugin.callHandlerInternal() → Feature Wrappers
              └─ Android: IaClientMethods.callHandler() → process method
```

## Callback Flow (Native → Dart → Host App)
```
Native SDK Event
  └─> iOS: IaClientDelegate callback methods
              └─> channel.invokeMethod("methodName", args)
      Android: IaClientCallbacks methods
              └─> channel.invokeMethod("methodName", args)
          └─ Dart: IaBaseCallbacks._handler
              └─> IaBaseCallbackHandler.handler()
                  └─> Host app callback (e.g., onSdkWillNavigateToTarget)
```

## Stream Listeners (Native → Dart)
Module-specific MethodChannel invocations that emit to StreamControllers.
Example: CardLink events use `StreamController<IaCardLinkEvent>` for real-time updates.

# Coding Tasks for Plugin

## General Notes
- The Flutter plugin is now modularized to mirror native SDK architecture
- Each module is a separate Flutter plugin package in `/modules/`
- Common interfaces live in `/interface/` package
- Core SDK logic lives in `/lib/`
- Plugin acts as proxy/mirror to native SDK - should not add additional functionality
- When sending with method channel from dart to native, always use map type for arguments (for JSON conversion)
- Each module has its own MethodChannel with unique channel ID (e.g., `"de.ihreapotheken/sdk/cardLink"`)

## How to Proxy SDK Function Through Plugin

Example: SDK has IACardLink.launch function, we want to enable flutter host app to call it.

### Step 1: Define in Interface
1. Add method signature to abstract class in `/interface/lib/src/modules/{module}/{module}.dart`
   Example: Add `launch()` to `IaBaseCardLink` in `/interface/lib/src/modules/cardlink/cardlink.dart`

### Step 2: Implement in Module (Dart)
1. Locate module: `/modules/{module}/lib/src/impl.dart`
2. Add method implementation that:
   - Creates request model if needed (in `/modules/{module}/lib/src/models/request/`)
   - Adds enum case to `_Methods` in `/modules/{module}/lib/src/methods.dart`
   - Calls `invoke()` (inherited from `IaBaseMethods`) with method enum and arguments

### Step 3: Implement in iOS
1. Add method handler in `/modules/{module}/ios/.../Methods/`
2. Handle method call in main plugin class (e.g., `IaSdkFlutterCardLink.swift`)
3. Call native SDK and return result

### Step 4: Implement in Android
1. Add method handler in `/modules/{module}/android/.../methods/`
2. Handle method call in main plugin class (e.g., `IaSdkFlutterCardLink.kt`)
3. Call native SDK and return result

## How to Proxy SDK View Through Plugin

### Step 1: Define View in Module
1. Add view definition to `/modules/{module}/lib/src/views.dart`
2. Create launch method in module's `impl.dart` using `IaBaseViews` mixin

### Step 2: Implement Native View Factory
- iOS: Handle in module's `IaSdkFlutter{Module}.swift`
- Android: Handle in module's `IaSdkFlutter{Module}.kt`

### Step 3: Add to Example App
Add button in appropriate view to launch the screen

## How to Proxy Callback Through Plugin (Native → Dart → Host App)

### How It Works
1. Native plugin code listens to SDK and passes events via method channel
2. Dart module receives via `IaBaseCallbacks._handler`
3. Handler processes and calls host app callback
4. If response needed, returns value to native

### Steps

#### Step 1: Create Handler (Dart)
1. Create handler class in `/modules/{module}/lib/src/callbacks/`
2. Extend `IaBaseCallbackHandler` with appropriate types
3. Implement `handler()` method

#### Step 2: Register Handler
1. Add callback property to module's callbacks class
2. Register handler in module's `_callbacks.dart`

#### Step 3: Implement iOS
1. Implement SDK delegate/listener in module's `Events/` directory
2. Send event via MethodChannel

#### Step 4: Implement Android
1. Implement SDK listener in module's `listeners/` directory
2. Send event via MethodChannel in `events/` directory

### Important
- Callbacks are optional (nullable) - provide sensible defaults if not set
- Use `Future<T>` for callbacks that need responses, `void` for fire-and-forget
- Stream listeners use `StreamController<T>` for continuous events

## How to Add Stream Listener

For continuous events (like CardLink session updates):

### Step 1: Define in Interface
Add `Stream<T>` getter to abstract class in `/interface/lib/src/modules/{module}/`

### Step 2: Implement in Module
1. Create `StreamController<T>` in module's `impl.dart`
2. Expose stream via getter
3. Handle incoming method channel calls to emit events

### Step 3: Native Implementation
- iOS: Use MethodChannel to send events to Dart
- Android: Use MethodChannel to send events to Dart

# Key Files Reference

| File | Purpose |
|------|---------|
| `/lib/src/core.dart` | Main SDK singleton with module getters and initialization |
| `/interface/lib/src/common/_interface.dart` | Abstract base classes for all implementations |
| `/modules/{module}/lib/src/impl.dart` | Concrete implementation of module interface |
| `/modules/{module}/lib/src/methods.dart` | Method definitions with channel routing |
| `/modules/{module}/ios/.../IaSdkFlutter{Module}.swift` | iOS module plugin class |
| `/modules/{module}/android/.../IaSdkFlutter{Module}.kt` | Android module plugin class |
| `/ios/.../IaClientBindings.swift` | Core iOS setup and method handler routing |
| `/ios/.../IaClientDelegate.swift` | Core iOS callback implementation |
| `/android/.../IaClientBindings.kt` | Core Android setup and method handler routing |
| `/android/.../IaClientCallbacks.kt` | Core Android callback implementation |
| `/example/lib/src/app.dart` | Demo app with navigation and feature showcase |
