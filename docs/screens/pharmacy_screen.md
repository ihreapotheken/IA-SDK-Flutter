# Pharmacy Screen

Displays detailed information about the currently selected pharmacy.

The pharmacy screen is part of the `ia_pharmacy` package.

## Launch
```dart
await IaSdk.instance.pharmacy.launchPharmacyDetails();
```

## Platform view
The pharmacy screen embedded in a tab bar, `viewId` is `pharmacyScreen`.

```dart
Scaffold(
  body: IndexedStack(
    index: _selectedIndex,
    children: const [
      IaSdkPlatformView(viewId: 'pharmacyScreen', selfSizing: false),
      // Your other tabs.
    ],
  ),
  bottomNavigationBar: NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (index) => setState(() => _selectedIndex = index),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.local_pharmacy), label: 'Pharmacy'),
      // Your other tabs.
    ],
  ),
)
```

> [!NOTE]
> Read [Presentation](../presentation.md) in order to understand how IA SDK screens can be presented in your app.
