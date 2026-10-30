# SDK Interaction

IA SDK allows the host app to receive events and override default behaviors. In Flutter there is no single delegate,
instead:
* **Streams** send you events, e.g. when the cart is updated. They are `StreamController`s, listen to their `stream`.
* **Callbacks** let you override default behaviors, e.g. what happens when the SDK wants to open the cart. They are
  function properties that you set.

Core streams and callbacks are on `IaSdk.instance`, module ones on the module, e.g. `IaSdk.instance.ordering`.

> [!TIP]
> It is best to listen to streams and set callbacks immediately after you call `register`, so you don't miss any
> events. Streams don't replay events that were sent before you started listening.

## Example of receiving SDK event
`orderingDidUpdateCartListener` sends the new cart state when the cart is updated.
```dart
IaSdk.instance.ordering.orderingDidUpdateCartListener.stream.listen((cartState) {
  print(cartState.totalAmountInCart);
});
```

Available streams:

| Stream | Event |
|---|---|
| `IaSdk.instance.initializationStateListener` | Initialization state changed |
| `IaSdk.instance.loggedAnalyticsEventListener` | Analytics event logged for the host app, e.g. `screen_view` or `purchase`, see [Analytics](#analytics) |
| `IaSdk.instance.logMessageListener` | SDK log message, for debugging (iOS only) |
| `IaSdk.instance.ordering.orderingDidUpdateCartListener` | Cart updated |
| `IaSdk.instance.ordering.orderingDidFinishOrderListener` | Order finished |
| `IaSdk.instance.prescription.scannerCameraErrorListener` | Scanner camera error (iOS only) |
| `IaSdk.instance.cardLink.*Listener` | CardLink events, e.g. `eventListener` and `prescriptionsRedeemedListener` |

## Example of overriding default behavior
`onSdkWillNavigateToTarget` is called when some overridable action is performed. Return `true` to let the SDK perform
its default behavior, or `false` when your app handled it.

On example of cart screen, if you don't set this callback, the default behavior is for the SDK to show its cart screen
over the current screen.

This behavior is fine in most cases, but if, for example, your app already includes a cart screen embedded inside a tab
bar, you can override this callback to switch to the cart tab instead of showing a new screen.

```dart
// We will switch to cart tab in our example app.
IaSdk.instance.onSdkWillNavigateToTarget = (navigationTarget) async {
  switch (navigationTarget) {
    case IaSdkNavigationTarget.cart:
      // Use this to select cart in your app, e.g.:
      // setState(() => _selectedTab = Tab.cart);
      return false;
    default:
      return true;
  }
};
```

> [!IMPORTANT]
> On Android, the SDK waits at most 500 ms for the answer, otherwise it performs its default behavior. Answer right
> away and do any slow work afterwards, or both your screen and the SDK's screen will be shown.

Navigation targets (`IaSdkNavigationTarget`):

| Target | When | Default behavior |
|---|---|---|
| `cart` | SDK wants to open the cart | Shows the SDK cart screen |
| `pharmacyDetails` | SDK wants to open the pharmacy details | Shows the SDK pharmacy screen |
| `apofinder` | SDK wants to open Apofinder, e.g. to change the pharmacy | Shows the SDK Apofinder |
| `thankYou` | Order and payment are processed | Shows the SDK thank you screen |
| `imprint` | "Impressum" footer button tapped | Shows the imprint from CMS |
| `start` | SDK wants to open the start screen (Android only) | Shows the SDK start screen |
| `search` | SDK wants to open the product search (Android only) | Shows the SDK product search |
| `redeemPrescription` | SDK wants to open the redeem prescription screen (Android only) | Shows the SDK screen |
| `thankYouCompleted` | User finished the thank you screen (Android only) | — |

## Other callbacks

| Callback | Called when |
|---|---|
| `IaSdk.instance.onApofinderDidChangePharmacy` | The user selects a pharmacy in Apofinder; gives the `pharmacyId` and `isFromPrerequisites` |
| `IaSdk.instance.prescription.onPrescriptionPhotoScanned` | A paper prescription is photographed; lets you take it over instead of the SDK |
| `IaSdk.instance.prescription.onEPrescriptionScanned` | An e-prescription (eRezept) is scanned; lets you take it over instead of the SDK |
| `IaSdk.instance.onSdkBackAction` | The user goes back on an SDK screen; decides whether the screen may close (Android only) |

## Analytics
The SDK sends no analytics anywhere itself. It logs events for the host app, which forwards them to its own analytics
tool. Events are only logged when the client has analytics enabled in the SDK's CMS and the user accepted analytics,
on the legal screen or the "Datenverarbeitung" screen. On Android they also need
`IaSdkConfiguration.isAnalyticsEnabled`, which is on by default.

Each event has a `name` from `IaSdkAnalyticsEventNames` and `parameters` keyed by `IaSdkAnalyticsParameterNames`.
No price or order value is included. New events are added over time, so handle unknown names.
```dart
IaSdk.instance.loggedAnalyticsEventListener.stream.listen((event) {
  switch (event.name) {
    case IaSdkAnalyticsEventNames.screenView:
      final screenName = event.parameters[IaSdkAnalyticsParameterNames.screenName];
      // Forward the screen view.
    default:
      // Forward event.name and event.parameters, or event.toJson().
  }
});
```

To ask the user again, clear their answer, so the legal screen shows the question the next time it runs:
```dart
await IaSdk.instance.resetAnalyticsConsent();
```

On Android, a host app that asks the user itself can also read and set the answer, after `initialize`:
```dart
final status = await IaSdk.instance.getAnalyticsConsentStatus();
await IaSdk.instance.setAnalyticsConsentStatus(IaSdkAnalyticsConsentStatus.accepted);
```

## Platform differences
- **Imprint:** On Android, `imprint` is only reported when `IaSdkConfigurationFooter.isImprintHandledByHostApp` is
  `true`, and then the SDK never shows its own imprint.
- **Screens opened without asking:** On Android, the screens opened from `IaProductGrid` (product details) and by
  `transferPrescriptions` don't call `onSdkWillNavigateToTarget`.
- **Cart state:** On Android, `orderingDidUpdateCartListener` only carries the counts (`totalProducts`,
  `totalPrescriptions`); on iOS it also carries the `products`.
- **Analytics events:** On Android, parameter values are always strings.
- **Pharmacy changes:** `onApofinderDidChangePharmacy` isn't called for Apofinder shown as a platform view. On Android
  it's only called for Apofinder opened with `launchApofinder`.
