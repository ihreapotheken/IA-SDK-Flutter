# IaCartButton

* `IaCartButton` is a UI component that displays a cart icon with the current item count, typically placed in an app
  bar or toolbar.
* By default, tapping the button opens the cart screen automatically, after asking
  `IaSdk.instance.onSdkWillNavigateToTarget`.
* Optionally, an `onTap` callback can be provided. In that case the host app is fully responsible for handling the tap
  and the cart is not opened automatically.

> [!IMPORTANT]
> SDK initialization and prerequisites (pharmacy selection) must be completed before using this component. To learn
> more, see [How to use components](how_to_use_components.md).

> [!NOTE]
> For a video of the component, see [IACartButton](https://github.com/ihreapotheken/IA-SDK-iOS/blob/main/Docs/Components/IACartButton.md)
> in the iOS SDK docs. It shows the iOS version.

## Overview
- Package: `ia_ordering`
- Dependencies:
  - None

## Parameters
- `onTap`: Called when the button is tapped. If set, the cart is not opened automatically. Switching between `null`
  and a callback recreates the button.

## Example

`IaCartButton` with default behaviour, the cart opens automatically on tap.

```dart
const IaCartButton()
```

`IaCartButton` with a custom tap handler.

```dart
IaCartButton(
  onTap: () {
    // Host app handles tap
  },
)
```

## Platform differences
- **Activity:** On Android the app's activity must be a `ComponentActivity`, such as `FlutterFragmentActivity`.
