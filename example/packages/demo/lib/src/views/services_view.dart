import 'dart:convert';
import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';
import 'package:ia_example_demo/ia_client_config.dart';
import 'package:ia_example_demo/src/actions.dart';
import 'package:ia_example_demo/src/views/startup_settings_view.dart';
import 'package:ia_example_shared/ia_example_shared.dart';

/// Calls the SDK's methods that don't open a screen, grouped by area.
///
class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final sdk = IaSdk.instance;
    Future<void> run(Future<String?> Function() call) => runAction(context, call);
    return IaTabListView(
      children: [
        const StartupSettingsSection(),
        IaSection(
          title: 'SDK state',
          children: [
            IaActionRow(
              title: 'Is Initialized',
              onTap: () => run(() async => 'isInitialized: ${await sdk.isInitialized()}'),
            ),
            IaActionRow(
              title: 'Get Initialization State',
              onTap: () => run(() async => 'Initialization state: ${(await sdk.getInitializationState()).name}'),
            ),
            IaActionRow(
              title: 'Get Environment',
              onTap: () => run(() async => 'Environment: ${(await sdk.getEnvironment()).name}'),
            ),
            IaActionRow(
              title: 'Reset Prerequisites',
              description: 'For testing only, restart needed',
              onTap: () => run(() async {
                await sdk.resetPrerequisites();
                return 'Prerequisites reset';
              }),
            ),
            IaActionRow(
              title: 'Reset Legal Disclaimer',
              description: 'Restart needed',
              platform: IaPlatform.ios,
              onTap: () => run(() async {
                await sdk.resetLegalDisclaimer();
                return 'Legal disclaimer reset';
              }),
            ),
            IaActionRow(
              title: 'Mark Onboarding Not Shown',
              description: 'Restart needed',
              platform: IaPlatform.ios,
              onTap: () => run(() async {
                await sdk.setIsOnboardingShown(isOnboardingShown: false);
                return 'Onboarding marked as not shown';
              }),
            ),
            IaActionRow(
              title: 'Reset Analytics Consent',
              description: Platform.isIOS ? 'Restart needed' : 'The legal screen asks again',
              onTap: () => run(() async {
                await sdk.resetAnalyticsConsent();
                return 'Analytics consent reset';
              }),
            ),
            IaActionRow(
              title: 'Is Prerequisite Flow Completed',
              platform: IaPlatform.android,
              onTap: () => run(() async => 'isPrerequisiteFlowCompleted: ${await sdk.isPrerequisiteFlowCompleted()}'),
            ),
          ],
        ),
        IaSection(
          title: 'Pharmacy',
          children: [
            IaActionRow(
              title: 'Get Pharmacy ID',
              onTap: () => run(() async => 'Pharmacy ID: ${await sdk.pharmacy.getPharmacyId() ?? 'none'}'),
            ),
            IaActionRow(
              title: 'Get Pharmacy',
              platform: IaPlatform.ios,
              onTap: () => run(() async {
                final pharmacy = await sdk.pharmacy.getPharmacy();
                return pharmacy == null ? 'No pharmacy selected' : '${pharmacy.name}, ${pharmacy.street}, ${pharmacy.city}';
              }),
            ),
            IaActionRow(
              title: 'Save Pharmacy ID Without Validation',
              platform: IaPlatform.ios,
              onTap: () async {
                final pharmacyId = await _promptForText(context, 'Pharmacy ID', initialValue: '2163');
                if (pharmacyId == null || !context.mounted) return;
                await run(() async {
                  await sdk.pharmacy.savePharmacyId(pharmacyId);
                  return 'Pharmacy ID $pharmacyId saved';
                });
              },
            ),
            IaActionRow(
              title: 'Clear Pharmacy ID',
              description: 'Restart needed',
              onTap: () => run(() async {
                await sdk.pharmacy.clearPharmacyId();
                return 'Pharmacy ID cleared';
              }),
            ),
          ],
        ),
        IaSection(
          title: 'Ordering',
          children: [
            IaActionRow(
              title: 'Get Cart Details',
              platform: IaPlatform.ios,
              onTap: () => run(() async {
                final details = await sdk.ordering.getCartDetails();
                return details == null ? 'Cart is empty' : 'Cart: ${const JsonEncoder.withIndent('  ').convert(details)}';
              }),
            ),
            IaActionRow(
              title: 'Get Cart State',
              platform: IaPlatform.ios,
              onTap: () => run(() async {
                final cart = await sdk.ordering.getCartState();
                return cart == null
                    ? 'Cart is empty'
                    : '${cart.totalAmountInCart} items: '
                          '${cart.products?.map((product) => '${product.pzn} x${product.amount}').join(', ')}';
              }),
            ),
            IaActionRow(
              title: 'Reload Cart and Emit Update',
              platform: IaPlatform.ios,
              onTap: () => run(() async {
                await sdk.ordering.getCartDetails(allowCached: false, shouldEmitCartUpdate: true);
                return 'Cart reloaded, see the Events tab';
              }),
            ),
            IaActionRow(
              title: 'Clear Cart',
              onTap: () => run(() async {
                await sdk.ordering.clearCart();
                return 'Cart cleared';
              }),
            ),
            IaActionRow(
              title: 'Delete Order History',
              platform: IaPlatform.ios,
              onTap: () => run(() async {
                await sdk.ordering.deleteOrderHistory();
                return 'Order history deleted';
              }),
            ),
            for (final variant in _transferVariants)
              IaActionRow(
                title: variant.label,
                description: 'Two photos, a PDF and an e-prescription',
                platform: variant.platform,
                onTap: () => run(() async {
                  await _transferMockPrescriptions(
                    finishAction: variant.finishAction,
                    showActivityIndicator: variant.showActivityIndicator,
                  );
                  return 'Prescriptions transferred';
                }),
              ),
          ],
        ),
        IaSection(
          title: 'User',
          children: [
            IaActionRow(
              title: 'Set Guest User Data',
              onTap: () => run(() async {
                await sdk.setGuestUserData(
                  salutation: 'Herr',
                  firstName: 'First',
                  lastName: 'Last',
                  email: 'email@example.org',
                  phoneNumberCountryCode: 49,
                  phoneNumberWithoutCountryCode: '432432243',
                );
                return 'Guest user data set';
              }),
            ),
            IaActionRow(
              title: 'Set Billing Address',
              onTap: () => run(() async {
                await sdk.setUserBillingAddress(
                  salutation: 'Herr',
                  firstName: 'First',
                  lastName: 'Last',
                  street: 'Musterstraße',
                  houseNumber: '1',
                  zipCode: '10115',
                  city: 'Berlin',
                  phoneNumberCountryCode: 49,
                  phoneNumberWithoutCountryCode: '432432243',
                );
                return 'Billing address set';
              }),
            ),
            IaActionRow(
              title: 'Set Delivery Address',
              onTap: () => run(() async {
                await sdk.setUserDeliveryAddress(
                  salutation: 'Herr',
                  firstName: 'First',
                  lastName: 'Last',
                  street: 'Musterstraße',
                  houseNumber: '2',
                  zipCode: '10115',
                  city: 'Berlin',
                );
                return 'Delivery address set';
              }),
            ),
            IaActionRow(
              title: 'Clear Billing and Delivery Addresses',
              onTap: () => run(() async {
                await sdk.clearUserBillingAddress();
                await sdk.clearUserDeliveryAddress();
                return 'Addresses cleared';
              }),
            ),
            IaActionRow(
              title: 'Delete User',
              platform: IaPlatform.ios,
              onTap: () => run(() async {
                await sdk.deleteUser();
                return 'User deleted';
              }),
            ),
            IaActionRow(
              title: 'Logout',
              description: 'Resets the user data, pharmacy and cart',
              onTap: () => run(() async {
                await sdk.logout();
                return 'Logged out';
              }),
            ),
            IaActionRow(
              title: 'Transfer SDK v1 User Data',
              onTap: () => run(() async {
                await sdk.transferSDKv1UserData();
                return 'SDK v1 user data transferred';
              }),
            ),
          ],
        ),
        IaSection(
          title: 'Appearance',
          children: [
            if (Platform.isIOS) const _MascotIllustrationsRow(),
            for (final isEnabled in [true, false])
              IaActionRow(
                title: '${isEnabled ? 'Enable' : 'Disable'} Haptic Feedback',
                platform: IaPlatform.android,
                onTap: () => run(() async {
                  await sdk.setHapticFeedbackEnabled(isEnabled: isEnabled);
                  return 'Haptic feedback ${isEnabled ? 'enabled' : 'disabled'}';
                }),
              ),
          ],
        ),
        IaSection(
          title: 'Debugging',
          children: [
            IaActionRow(title: 'Present Logs', onTap: () => runLaunch(context, sdk.presentLogs)),
            IaActionRow(
              title: 'Export Logs',
              platform: IaPlatform.android,
              onTap: () => run(() async => 'Logs: ${await sdk.exportLogs()}'),
            ),
            IaActionRow(
              title: 'Get User ID',
              platform: IaPlatform.ios,
              onTap: () => run(() async => 'User ID: ${await sdk.getUserId() ?? 'none'}'),
            ),
          ],
        ),
        if (Platform.isIOS)
          IaSection(
            title: 'Cache',
            children: [
              IaActionRow(
                title: 'Clean Cache',
                description: 'For testing only, restart needed',
                platform: IaPlatform.ios,
                onTap: () => run(() async {
                  await sdk.cleanCache(initialization: true, prerequisites: true);
                  return 'Cache cleaned';
                }),
              ),
              IaActionRow(
                title: 'Remove All Cached Responses',
                description: 'For testing only, restart needed',
                platform: IaPlatform.ios,
                onTap: () => run(() async {
                  await sdk.removeAllCachedResponses();
                  return 'Cached responses removed';
                }),
              ),
              IaActionRow(
                title: 'Clear Product Grid Cache',
                description: 'For testing only, restart needed',
                platform: IaPlatform.ios,
                onTap: () => run(() async {
                  await sdk.overTheCounter.clearProductGridCache();
                  return 'Product grid cache cleared';
                }),
              ),
            ],
          ),
      ],
    );
  }

  static const _transferVariants =
      <({String label, IaTransferPrescriptionsFinishAction finishAction, bool showActivityIndicator, IaPlatform? platform})>[
        (
          label: 'Transfer Prescriptions, Open Cart',
          finishAction: IaTransferPrescriptionsFinishAction.openCart,
          showActivityIndicator: true,
          platform: null,
        ),
        (
          label: 'Transfer Prescriptions, Bottom Sheet',
          finishAction: IaTransferPrescriptionsFinishAction.showBottomSheet,
          showActivityIndicator: true,
          platform: null,
        ),
        (
          label: 'Transfer Prescriptions, No Action or Indicator',
          finishAction: IaTransferPrescriptionsFinishAction.noAction,
          showActivityIndicator: false,
          platform: IaPlatform.ios,
        ),
      ];

  static Future<void> _transferMockPrescriptions({
    required IaTransferPrescriptionsFinishAction finishAction,
    required bool showActivityIndicator,
  }) {
    return IaSdk.instance.ordering.transferPrescriptions(
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
      finishAction: finishAction,
      showActivityIndicator: showActivityIndicator,
    );
  }

  /// Asks for a text value, `null` when cancelled.
  ///
  static Future<String?> _promptForText(BuildContext context, String title, {String initialValue = ''}) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(controller: controller, autofocus: true),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('OK')),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }
}

/// Runtime switch for the Pharmi mascot illustrations.
///
/// The mascot renders on the CardLink FAQ screen, so flip this and then open
/// CardLink → Launch CardLink → FAQ to see the change. Screens already on
/// screen keep the value they were built with.
///
/// iOS only: Android's native UI configuration is immutable after init, so the
/// mascot is set there with the "Mascot illustrations" startup setting instead,
/// see [StartupSettingsSection].
class _MascotIllustrationsRow extends StatefulWidget {
  const _MascotIllustrationsRow();

  @override
  State<_MascotIllustrationsRow> createState() => _MascotIllustrationsRowState();
}

class _MascotIllustrationsRowState extends State<_MascotIllustrationsRow> {
  /// Seeded from the value the SDK was initialized with, so the switch
  /// starts out reflecting the SDK's actual state.
  bool _shouldShow = ExampleAppConfig.instance.pluginConfig.uiConfiguration.shouldShowMascotIllustrations;

  Future<void> _setShouldShow(bool shouldShow) {
    return runAction(context, () async {
      await IaSdk.instance.setShouldShowMascotIllustrations(shouldShowMascotIllustrations: shouldShow);
      if (mounted) setState(() => _shouldShow = shouldShow);
      return 'Mascot illustrations ${shouldShow ? 'enabled' : 'disabled'}. Open CardLink → FAQ to see the change.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return IaSwitchRow(
      title: 'Mascot illustrations',
      description: 'Pharmi on the CardLink FAQ screen',
      platform: IaPlatform.ios,
      value: _shouldShow,
      onChanged: _setShouldShow,
    );
  }
}
