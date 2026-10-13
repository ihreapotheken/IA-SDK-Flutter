import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/testing/event_log.dart';
import 'package:flutter/material.dart';

class ScreensView extends StatelessWidget {
  const ScreensView({super.key});

  /// Opens the photo scanner, then turns the flashlight on and off, and pauses and resumes the preview.
  ///
  static Future<void> _runScannerCameraTest() async {
    final prescription = IaSdk.instance.prescription;
    final log = ExampleEventLog.instance;
    await prescription.launchPrescriptionScanner(IaPrescriptionScannerType.prescription);
    final steps = <(String, Future<void> Function())>[
      ('Flashlight on', () => prescription.setScannerCameraState(isFlashlightOn: true)),
      ('Flashlight off', () => prescription.setScannerCameraState(isFlashlightOn: false)),
      ('Preview paused', () => prescription.setScannerCameraState(isPreviewPaused: true)),
      ('Preview resumed', () => prescription.setScannerCameraState(isPreviewPaused: false)),
    ];
    for (final (label, step) in steps) {
      await Future<void>.delayed(const Duration(seconds: 2));
      try {
        await step();
        log.add('Scanner camera test', label);
      } catch (e) {
        log.add('Scanner camera test', '$label failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        24 + MediaQuery.of(context).padding.top,
        20,
        24,
      ),
      children: [
        ElevatedButton(
          child: Text('Launch Start screen'),
          onPressed: () => IaSdk.instance.launchStartRoute(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Product Search'),
          onPressed: () => IaSdk.instance.overTheCounter.launchProductSearchRoute(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Product Search, focused (iOS)'),
          onPressed: () => IaSdk.instance.overTheCounter.launchProductSearchRoute(focusesOnAppear: true),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Cart Screen'),
          onPressed: () => IaSdk.instance.ordering.launchCartScreen(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Pharmacy Details'),
          onPressed: () => IaSdk.instance.pharmacy.launchPharmacyDetails(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Apofinder'),
          onPressed: () => IaSdk.instance.launchApofinder(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Apofinder, not cancellable (iOS)'),
          onPressed: () => IaSdk.instance.launchApofinder(isCancellable: false),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Redeem Prescription'),
          onPressed: () => IaSdk.instance.prescription.launchRedeemPrescriptionScreen(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Prescription Photo Scanner (iOS)'),
          onPressed: () => IaSdk.instance.prescription.launchPrescriptionScanner(
            IaPrescriptionScannerType.prescription,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch E-Prescription Scanner (iOS)'),
          onPressed: () => IaSdk.instance.prescription.launchPrescriptionScanner(
            IaPrescriptionScannerType.ePrescription,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          // The scanner covers the app, so the camera changes run on a timer while it's open.
          child: Text('Scanner Camera Test (iOS)'),
          onPressed: _runScannerCameraTest,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Prerequisite Flow (Android)'),
          onPressed: () => IaSdk.instance.launchPrerequisiteFlow(),
        ),
      ],
    );
  }
}
