# Apofinder Screen

A screen that allows users to select a pharmacy by searching and filtering pharmacies, in a list or on a map.

Apofinder is part of the core package, `appsdk_v2_flutter_plugin`.

## Launch
```dart
await IaSdk.instance.launchApofinder(isCancellable: true);
```

**Parameters**
  - **isCancellable**: When `false`, users cannot dismiss or go back, they must select a pharmacy. When `true`, a
    dismiss button is shown. Defaults to `true`.

The selected pharmacy is reported through `IaSdk.instance.onApofinderDidChangePharmacy`, see
[SDK Interaction](../interaction.md).

## Platform view
Apofinder presented over your app, `viewId` is `apofinderScreen`.

```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (context) => Scaffold(
      body: IaSdkPlatformView(
        viewId: 'apofinderScreen',
        selfSizing: false,
        embedStyle: IaSdkScreenEmbedStyle.presentation,
        // Called when the user selects a pharmacy or closes Apofinder.
        onDismiss: () => Navigator.of(context).pop(),
      ),
    ),
  ),
);
```

> [!NOTE]
> Read [Presentation](../presentation.md) in order to understand how IA SDK screens can be presented in your app.

## Platform differences
- **isCancellable:** Only used on iOS.
- **onDismiss:** Only used on iOS, where it's also called when the user selects a pharmacy.
- **onApofinderDidChangePharmacy:** Not called for Apofinder shown as a platform view.
