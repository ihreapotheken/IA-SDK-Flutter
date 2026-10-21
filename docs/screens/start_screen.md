# Start Screen

Acts as the central hub for the IhreApotheken experience, giving users quick access to:
  * Pharmacy details
  * Search and filter products
  * Scan prescriptions
  * Recent orders
  * Cart
  * Product recommendations

The start screen is part of the core package, `appsdk_v2_flutter_plugin`. Some of its sections are shown only when the
module they need is registered, e.g. the cart button with `ia_ordering`.

## Launch
```dart
await IaSdk.instance.launchStartRoute();
```

## Platform view
The start screen embedded in a tab bar, `viewId` is `startScreen`.

```dart
Scaffold(
  body: IndexedStack(
    index: _selectedIndex,
    children: const [
      IaSdkPlatformView(viewId: 'startScreen', selfSizing: false),
      // Your other tabs.
    ],
  ),
  bottomNavigationBar: NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (index) => setState(() => _selectedIndex = index),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      // Your other tabs.
    ],
  ),
)
```

> [!NOTE]
> Read [Presentation](../presentation.md) in order to understand how IA SDK screens can be presented in your app.
