# Appearance

The appearance of SDK screens is set with `IaSdkConfiguration.uiConfiguration`, which you pass to `initialize`. This
way all adjustments are applied before the prerequisites run or any SDK screen is shown.

```dart
await IaSdk.instance.initialize(
  config: IaSdkConfiguration(
    accessKey: 'ENTER YOUR API KEY HERE',
    clientId: 'ENTER YOUR CLIENT ID HERE',
    serverEnvironment: IaSdkConfigurationServerEnvironment.production,
    shouldFetchThemeFromRemote: false, // See Remote Theme below.
    uiConfiguration: const IaUIConfiguration(
      // Appearance options described below.
    ),
  ),
);
```

## Navigation Bar Appearance

The Navigation Bar used throughout SDKs generates colors based on the Primary Color set on BEP. You can override these
colors using the header configuration like so:

```dart
const IaUIConfiguration(
  header: IaHeaderConfiguration(
    primaryColor: Colors.blue,
    secondaryColor: Colors.green,
  ),
)
```

The secondary color corresponds to the color of the custom graphic in the background of the Navigation Bar. You can
remove the custom graphic by doing the following:

```dart
const IaUIConfiguration(
  header: IaHeaderConfiguration(
    style: IaHeaderStyle.monotone, // default is duotone
  ),
)
```

## Primary & Secondary Buttons Appearance

You can adjust the appearance of Primary and Secondary Buttons by setting custom background, text and border colors,
border radius and border width, as well as customize their appearance when they are disabled. Here is an example of how
you can adjust the appearance of the Primary Button:

```dart
const IaUIConfiguration(
  primaryButton: IaPrimaryButtonConfiguration(
    backgroundColor: Color(0xFF990000),
    backgroundDisabledColor: Colors.grey,
    textColor: Color(0xFFEEEEEE),
    textDisabledColor: Colors.black,
    borderColor: Color(0xFFBBBBBB),
    borderDisabledColor: Colors.black,
    borderWidth: 4,
    borderRadius: 0,
  ),
)
```

The Secondary Button has the same properties as the Primary Button. To adjust its appearance, use `secondaryButton`
with `IaSecondaryButtonConfiguration` instead.

## Mascot Illustrations

SDK screens show the Pharmi mascot illustrations. If your app shouldn't carry Ihre Apotheken character branding (e.g. a
white-label app), you can hide them. The surrounding layout collapses, so no empty space is left behind:

```dart
const IaUIConfiguration(
  shouldShowMascotIllustrations: false,
)
```

## Remote Theme

The theme of SDK screens can be loaded remotely, with `IaSdkConfiguration.shouldFetchThemeFromRemote`. When it's set
to `true` (the default), `initialize` fetches the whole color palette and the fonts configured for your API key, so the
SDK screens match your brand without any code changes. Set it to `false` to use only the SDK's local theme and your
`uiConfiguration`.

```dart
IaSdkConfiguration(
  // ...
  shouldFetchThemeFromRemote: true,
)
```

## iOS specific

### Liquid Glass

IA SDKs support Liquid Glass, starting from iOS 26.0.

To enable it, make sure you set `UIDesignRequiresCompatibility` to `false` in your `ios/Runner/Info.plist`. Then set
`supportsLiquidGlass` to `true`:

```dart
const IaUIConfiguration(
  supportsLiquidGlass: true,
)
```

**Note**: If you do not set `supportsLiquidGlass` to `true`, there will be some visual artifacts.

### Bouncy ScrollViews

SDK screens use scroll views which have `bounces` enabled by default. If you wish to disable the native
bouncing of scroll views, add the following to your `ios/Runner/AppDelegate.swift` before any SDK screen is shown:

```swift
UIScrollView.appearance().bounces = false
```

**Note**: This method is not recommended as it will disable bouncing for all native scroll views inside your app,
which might be unwanted behaviour.

### Changing Mascot Illustrations later

You can change `shouldShowMascotIllustrations` after `initialize` with:

```dart
await IaSdk.instance.setShouldShowMascotIllustrations(shouldShowMascotIllustrations: false);
```

Screens shown after the call use the new value.
