import 'dart:convert';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/ia_client_config.dart';
import 'package:flutter/material.dart';

class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

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
          child: Text('Clear Cart'),
          onPressed: _onClearCartPressed,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Set guest user data'),
          onPressed: _onSetGuestUserDataPressed,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Logout'),
          onPressed: _onLogoutPressed,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Transfer prescriptions'),
          onPressed: _onTransferPrescriptionsPressed,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Transfer SDK v1 user data'),
          onPressed: _onTransferSDKv1UserDataPressed,
        ),
      ],
    );
  }

  Future<void> _onClearCartPressed() async {
    await IaSdk.instance.ordering.clearCart();
  }

  Future<void> _onSetGuestUserDataPressed() async {
    await IaSdk.instance.setGuestUserData(
      salutation: 'Herr',
      firstName: 'First',
      lastName: 'Last',
      email: 'email@example.org',
      phoneNumberCountryCode: 49,
      phoneNumberWithoutCountryCode: 432432243,
    );
  }

  Future<void> _onLogoutPressed() async {
    await IaSdk.instance.logout();
  }

  Future<void> _onTransferPrescriptionsPressed() async {
    try {
      await IaSdk.instance.ordering.transferPrescriptions(
        images: [
          base64Decode(ExampleAppConfig.instance.mockPngPrescription),
          base64Decode(ExampleAppConfig.instance.mockJpgPrescription),
        ],
        pdfs: [
          (
            data: base64Decode(ExampleAppConfig.instance.mockPdfPrescription),
            insuranceType: IaPrescriptionInsuranceType.privateInsurance,
          ),
        ],
        codes: [
          '{"urls":["Task/test9ba2fee0d07e4ef2b6205f8012e1445b/\$accept?ac=5e24cc059ff244bdbb01efcccf834a6329bdac67a4a64733938fe1b799ac19a9"]}',
        ],
        orderId: 'Some order id from host app',
      );
    } catch (e) {
      debugPrint('ERROR TRANSFER');
      debugPrint('$e', wrapWidth: 999999999999);
    }
  }

  Future<void> _onTransferSDKv1UserDataPressed() async {
    try {
      await IaSdk.instance.transferSDKv1UserData();
    } catch (e) {
      debugPrint('ERROR TRANSFER SDK V1 USER DATA');
      debugPrint('$e', wrapWidth: 999999999999);
    }
  }
}
