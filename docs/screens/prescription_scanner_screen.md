# Prescription Scanner Screen

A camera screen for adding a prescription. Depending on the `type`, it lets the user:
- Take a photo of a paper prescription (or select one from the gallery)
- Scan the QR code of an electronic prescription (E-Prescription)

Use it when you already know how the user wants to add the prescription. To let the user choose the method, use the
[Redeem Prescription Screen](redeem_prescription_screen.md) instead.

The prescription is automatically added to the cart, which can be overridden with `onPrescriptionPhotoScanned` and
`onEPrescriptionScanned`, see [SDK Interaction](../interaction.md).

The prescription scanner is part of the `ia_prescription` package.

## Launch
```dart
await IaSdk.instance.prescription.launchPrescriptionScanner(IaPrescriptionScannerType.prescription);
```

**Parameters**
  - **type**: `IaPrescriptionScannerType.prescription` (capture photo) or `IaPrescriptionScannerType.ePrescription`
    (scan electronic prescription).

While the scanner is shown, you can control its camera with `setScannerCameraState`, and listen to camera errors with
`scannerCameraErrorListener`:

```dart
await IaSdk.instance.prescription.setScannerCameraState(isFlashlightOn: true);
```

The scanner can't be shown as a platform view.

> [!NOTE]
> Read [Presentation](../presentation.md) in order to understand how IA SDK screens can be presented in your app.

## Platform differences
- **Availability:** Only on iOS. On Android, open the scanners from the
  [Redeem Prescription Screen](redeem_prescription_screen.md).
