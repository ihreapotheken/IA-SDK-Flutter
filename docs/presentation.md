# Presentation

SDK screens can be shown in two ways:
* **Launch methods (recommended):** the SDK opens the screen on top of your app and takes care of its navigation.
* **Screen widgets (platform views):** you put the screen into your own UI with its widget, such as `IaCartScreen`,
  and push, present or embed it yourself (e.g. in a tab bar).

**IMPORTANT:** Before doing any of this, make sure that `initialize` has completed. See
[Initialization](initialization.md).

## Launch methods (recommended)
Launch methods are the preferred way to show SDK screens. The native SDK shows the screen itself, so there is one
wrapper less between your app and the SDK (no Flutter platform view), which means fewer problems with layout,
gestures, keyboard and navigation.

```dart
// Start screen, from the core package.
await IaSdk.instance.launchStartRoute();

// Product search, from ia_over_the_counter.
await IaSdk.instance.overTheCounter.launchProductSearchRoute();

// Cart, from ia_ordering.
await IaSdk.instance.ordering.launchCartScreen();
```

Available launch methods:

| Method | Package |
|---|---|
| `IaSdk.instance.launchStartRoute()` | `appsdk_v2_flutter_plugin` |
| `IaSdk.instance.launchApofinder()` | `appsdk_v2_flutter_plugin` |
| `IaSdk.instance.overTheCounter.launchProductSearchRoute()` | `ia_over_the_counter` |
| `IaSdk.instance.ordering.launchCartScreen()` | `ia_ordering` |
| `IaSdk.instance.pharmacy.launchPharmacyDetails()` | `ia_pharmacy` |
| `IaSdk.instance.prescription.launchRedeemPrescriptionScreen()` | `ia_prescription` |
| `IaSdk.instance.prescription.launchPrescriptionScanner(type)` (iOS only) | `ia_prescription` |
| `IaSdk.instance.cardLink.launch(...)` | `ia_cardlink` |

The SDK handles the navigation of launched screens, including closing them. To close all SDK screens from your code,
call `IaSdk.instance.finishAllActivities()`.

## Screen widgets
Use a screen widget when you need to control how the screen is shown: push it to your navigation, present it
yourself, or embed it into your UI. Each package exports the widgets of its screens:

| Widget | Screen | Package |
|---|---|---|
| `IaStartScreen` | Start screen | `appsdk_v2_flutter_plugin` |
| `IaApofinderScreen` | Apofinder | `appsdk_v2_flutter_plugin` |
| `IaProductSearchScreen` | Product search | `ia_over_the_counter` |
| `IaCartScreen` | Cart | `ia_ordering` |
| `IaPharmacyScreen` | Pharmacy details | `ia_pharmacy` |
| `IaRedeemPrescriptionScreen` | Redeem prescription | `ia_prescription` |

Screens fill the space you give them, so give them bounded constraints, e.g. as the body of a `Scaffold`. Each screen
is a native platform view; the widgets build on `IaSdkPlatformView`, which you can also use directly with the screen's
`viewId` (e.g. `cartScreen`).

You can specify `embedStyle`, this determines if the SDK screen shows a back button
(`IaSdkScreenEmbedStyle.navigation`), a close button (`IaSdkScreenEmbedStyle.presentation`) or no button (`null`) in
its navigation. When the user taps that button, `onDismiss` is called. Note that `embedStyle` doesn't actually push,
present or embed, you are responsible for that, as with any other widget. The SDK reads `embedStyle` and the other
options once, when it creates the screen.

When the module of a screen isn't registered, or your backend configuration doesn't include its feature, the SDK
shows a screen saying that the feature isn't available.

### Embed
```dart
class ExampleTabs extends StatefulWidget {
  const ExampleTabs({super.key});

  @override
  State<ExampleTabs> createState() => _ExampleTabsState();
}

class _ExampleTabsState extends State<ExampleTabs> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          IaProductSearchScreen(),
          IaCartScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}
```

### Push to navigation
```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (context) => Scaffold(
      body: IaProductSearchScreen(
        embedStyle: IaSdkScreenEmbedStyle.navigation,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    ),
  ),
);
```

### Present
```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (context) => Scaffold(
      body: IaProductSearchScreen(
        embedStyle: IaSdkScreenEmbedStyle.presentation,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    ),
  ),
);
```

## Platform differences
- **Close button:** The Android SDK has no close button, so `IaSdkScreenEmbedStyle.presentation` shows a back button
  there.
- **`onDismiss`:** On Android the SDK also asks to close the screen when its flow ends in another way, for example when
  the user goes back from the first screen of the flow, also without an `embedStyle`. The system back action closes
  the route as for any other one.
- **Activity:** On Android the app's activity must be a `ComponentActivity`, such as `FlutterFragmentActivity`.
- **Options:** `IaApofinderScreen(isCancellable:)` and `IaProductSearchScreen(focusesOnAppear:)` are only used on iOS,
  as for the launch methods.
- **Scanners:** The prescription scanners can't be shown as platform views. On iOS use `launchPrescriptionScanner`, on
  Android open them from the redeem prescription screen.
