# Product Search Screen

This screen serves as a starting point for product search. It offers following features:
* **Search screen:** Search bar with list of products, allows filtering and sorting.
* **Product details:** Displays details of a selected product.
* **Product inquiry:** Enables the user to send an email to pharmacies and inquire about the product.
* **Cart integration:** The cart is integrated into the list and details if `ia_ordering` is registered.
* **Product scanner:** Users can simply scan the product instead of searching it.

The product search screen is part of the `ia_over_the_counter` package.

## Launch
```dart
await IaSdk.instance.overTheCounter.launchProductSearchRoute(focusesOnAppear: true);
```

**Parameters**
  - **focusesOnAppear**: Whether the search field is focused when the screen opens. When not set, the SDK default is
    used.

## Platform view
The product search screen embedded in a tab bar, `viewId` is `searchScreen`.

```dart
Scaffold(
  body: IndexedStack(
    index: _selectedIndex,
    children: const [
      IaSdkPlatformView(viewId: 'searchScreen', selfSizing: false),
      // Your other tabs.
    ],
  ),
  bottomNavigationBar: NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (index) => setState(() => _selectedIndex = index),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
      // Your other tabs.
    ],
  ),
)
```

> [!NOTE]
> Read [Presentation](../presentation.md) in order to understand how IA SDK screens can be presented in your app.

## Platform differences
- **focusesOnAppear:** Only used on iOS.
