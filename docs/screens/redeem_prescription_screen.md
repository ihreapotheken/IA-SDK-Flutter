# Redeem Prescription Screen

Screen for redeeming prescriptions and adding them to the cart.

This screen shows the following options for redeeming prescriptions:
- CardLink (requires `ia_cardlink`): read the electronic health card via NFC.
- Photo capture: take a photo of a prescription or choose one from the gallery.
- QR code scanning: scan a prescription QR code.

Options that aren't available are hidden. Prescriptions are uploaded to the cart only if `ia_ordering` is registered.

Your app can use the following to override the default behavior, see [SDK Interaction](../interaction.md):
  - `onPrescriptionPhotoScanned` and `onEPrescriptionScanned`: Get the prescription data instead of uploading it to
    the cart, e.g. if you are not using `ia_ordering`.
  - `onSdkWillNavigateToTarget`: After a prescription is uploaded, the user can go to the cart. You can override it to
    show the cart inside your own UI, otherwise the cart is shown above everything.

The redeem prescription screen is part of the `ia_prescription` package.

## Launch
```dart
await IaSdk.instance.prescription.launchRedeemPrescriptionScreen();
```

## Platform view
The redeem prescription screen embedded in a tab bar, `viewId` is `redeemPrescription`.

```dart
Scaffold(
  body: IndexedStack(
    index: _selectedIndex,
    children: const [
      IaSdkPlatformView(viewId: 'redeemPrescription', selfSizing: false),
      // Your other tabs.
    ],
  ),
  bottomNavigationBar: NavigationBar(
    selectedIndex: _selectedIndex,
    onDestinationSelected: (index) => setState(() => _selectedIndex = index),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Prescriptions'),
      // Your other tabs.
    ],
  ),
)
```

> [!NOTE]
> Read [Presentation](../presentation.md) in order to understand how IA SDK screens can be presented in your app.
