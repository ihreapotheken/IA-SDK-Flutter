import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';

class ScreensView extends StatelessWidget {
  const ScreensView({super.key});

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
          child: Text('Turn On Scanner Flashlight (iOS)'),
          onPressed: () => IaSdk.instance.prescription.setScannerCameraState(isFlashlightOn: true),
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
