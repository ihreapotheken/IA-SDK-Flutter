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
          child: Text('Launch Redeem Prescription'),
          onPressed: () => IaSdk.instance.prescription.launchRedeemPrescriptionScreen(),
        ),
      ],
    );
  }
}
