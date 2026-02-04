# IA SDK Flutter Plugin Example

This example app demonstrates how to integrate and use the IA SDK Flutter plugin.

## Prerequisites

- Flutter >= 3.30.0
- Dart SDK >= 3.10.0
- iOS or Android development environment set up

## Environment Setup

The example app requires an SDK access key to authenticate with the ia.de backend services.

### Option 1: Using a .secrets file (Recommended)

1. Create a `.secrets` file in the `example/` directory:
   ```
   APPSDK_ACCESS_KEY=your_access_key_here
   ```

2. The `.secrets` file is already included in `.gitignore` and will not be committed to source control.

### Option 2: Using dart-define

Pass the access key as a compile-time variable:
```bash
flutter run --dart-define iaAccessKey=your_access_key_here
```

## Running the Example

```bash
cd example
flutter pub get
flutter run
```

## App Structure

The example app contains four main tabs demonstrating different SDK features:

### Host App Tab
Displays a map with pharmacy markers. Tapping a marker shows a bottom sheet where you can:
- Select a pharmacy by ID
- Launch the SDK start route
- Open a web browser overlay

### CardLink Tab
Demonstrates the CardLink module for NFC-based prescription transfer:
- Launch CardLink SDK flow
- Launch Saved Cards flow
- Get SDK version and environment info
- Manage saved cards (get/delete)

### Services Tab
Demonstrates various SDK service methods:
- Clear shopping cart
- Set guest user data
- Logout
- Transfer prescriptions (images, PDFs, codes)

### Screens Tab
Demonstrates launching SDK screens directly:
- Start screen
- Product search
- Cart screen
- Pharmacy details

## SDK Initialization

The SDK is initialized in [sdk_initializer.dart](lib/src/services/sdk_initializer.dart). The initialization process includes:

1. **Setting up callbacks** - Handle SDK navigation events
2. **Registering modules** - CardLink, Ordering, OverTheCounter, Pharmacy, Prescription
3. **Initializing the SDK** - Pass configuration with access key
4. **Setting up event listeners** - Listen for ordering and CardLink events

## Configuration

SDK configuration is managed in [ia_client_config.dart](lib/ia_client_config.dart). Key configuration options include:
- `accessKey` - Authentication key (from .env or dart-define)
- `clientId` - Client identifier
- `serverEnvironment` - Backend environment (debug/production)
