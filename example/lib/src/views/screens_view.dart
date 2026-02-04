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
          onPressed: _onLaunchStartScreenPressed,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Product Search'),
          onPressed: _onLaunchProductSearchPressed,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Cart Screen'),
          onPressed: _onLaunchCartScreenPressed,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Launch Pharmacy Details'),
          onPressed: _onLaunchPharmacyDetailsPressed,
        ),
      ],
    );
  }

  Future<void> _onLaunchStartScreenPressed() async {
    await IaSdk.instance.launchStartRoute();
  }

  Future<void> _onLaunchProductSearchPressed() async {
    await IaSdk.instance.overTheCounter.launchProductSearchRoute();
  }

  Future<void> _onLaunchCartScreenPressed() async {
    await IaSdk.instance.ordering.launchCartScreen();
  }

  Future<void> _onLaunchPharmacyDetailsPressed() async {
    await IaSdk.instance.pharmacy.launchPharmacyDetails();
  }
}
