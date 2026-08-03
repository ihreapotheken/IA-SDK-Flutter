import 'dart:convert';
import 'dart:io';

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
        _SectionHeader(title: 'SDK State'),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Is Initialized'),
          onPressed: () async {
            final result = await IaSdk.instance.isInitialized();
            if (context.mounted) _showResult(context, 'isInitialized: $result');
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Environment (iOS)'),
          onPressed: () async {
            try {
              final env = await IaSdk.instance.getEnvironment();
              if (context.mounted) _showResult(context, 'Environment: ${env?.name ?? 'N/A'}');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Pharmacy'),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Pharmacy ID'),
          onPressed: () async {
            try {
              final id = await IaSdk.instance.pharmacy.getPharmacyId();
              if (context.mounted) _showResult(context, 'Pharmacy ID: ${id ?? 'none'}');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Ordering'),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Cart Details (iOS)'),
          onPressed: () async {
            try {
              final details = await IaSdk.instance.ordering.getCartDetails();
              if (context.mounted) {
                if (details == null) {
                  _showResult(context, 'Cart is empty');
                } else {
                  _showResult(context, 'Cart: ${const JsonEncoder.withIndent('  ').convert(details)}');
                }
              }
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Clear Cart'),
          onPressed: () => IaSdk.instance.ordering.clearCart(),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Delete Order History (iOS)'),
          onPressed: () async {
            try {
              await IaSdk.instance.ordering.deleteOrderHistory();
              if (context.mounted) _showResult(context, 'Order history deleted');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Transfer prescriptions'),
          onPressed: () async {
            try {
              await IaSdk.instance.ordering.transferPrescriptions(
                images: [
                  base64Decode(ExampleAppConfig.instance.mockPngPrescription),
                  base64Decode(ExampleAppConfig.instance.mockJpgPrescription),
                ],
                pdfs: [
                  (
                    data: base64Decode(
                      ExampleAppConfig.instance.mockPdfPrescription,
                    ),
                    insuranceType:
                        IaPrescriptionInsuranceType.privateInsurance,
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
          },
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'User'),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Set guest user data'),
          onPressed: () => IaSdk.instance.setGuestUserData(
            salutation: 'Herr',
            firstName: 'First',
            lastName: 'Last',
            email: 'email@example.org',
            phoneNumberCountryCode: 49,
            phoneNumberWithoutCountryCode: 432432243,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Set billing address (iOS)'),
          onPressed: () async {
            try {
              await IaSdk.instance.setUserBillingAddress(
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
              if (context.mounted) _showResult(context, 'Billing address set');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Set delivery address (iOS)'),
          onPressed: () async {
            try {
              await IaSdk.instance.setUserDeliveryAddress(
                salutation: 'Herr',
                firstName: 'First',
                lastName: 'Last',
                street: 'Musterstraße',
                houseNumber: '2',
                zipCode: '10115',
                city: 'Berlin',
              );
              if (context.mounted) _showResult(context, 'Delivery address set');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Delete User (iOS)'),
          onPressed: () async {
            try {
              await IaSdk.instance.deleteUser();
              if (context.mounted) _showResult(context, 'User deleted');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Logout'),
          onPressed: () => IaSdk.instance.logout(),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Transfer SDK v1 user data'),
          onPressed: () async {
            try {
              await IaSdk.instance.transferSDKv1UserData();
            } catch (e) {
              debugPrint('ERROR TRANSFER SDK V1 USER DATA');
              debugPrint('$e', wrapWidth: 999999999999);
            }
          },
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Appearance'),
        const SizedBox(height: 8),
        const _MascotIllustrationsToggle(),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Cache'),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Clean Cache (iOS)'),
          onPressed: () async {
            try {
              await IaSdk.instance.cleanCache(
                initialization: true,
                prerequisites: true,
              );
              if (context.mounted) _showResult(context, 'Cache cleaned');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
      ],
    );
  }

  void _showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Runtime toggle for the Pharmi mascot illustrations.
///
/// The mascot renders on the CardLink FAQ screen, so flip this and then open
/// CardLink → Launch CardLink → FAQ to see the change. Screens already on
/// screen keep the value they were built with.
class _MascotIllustrationsToggle extends StatefulWidget {
  const _MascotIllustrationsToggle();

  @override
  State<_MascotIllustrationsToggle> createState() {
    return _MascotIllustrationsToggleState();
  }
}

class _MascotIllustrationsToggleState
    extends State<_MascotIllustrationsToggle> {
  /// Seeded from the value the SDK was initialized with, so the button label
  /// starts out reflecting the SDK's actual state.
  bool _shouldShow = ExampleAppConfig
      .instance
      .pluginConfig
      .uiConfiguration
      .shouldShowMascotIllustrations;

  Future<void> _toggle() async {
    final next = !_shouldShow;
    try {
      await IaSdk.instance.setShouldShowMascotIllustrations(
        shouldShowMascotIllustrations: next,
      );
      setState(() => _shouldShow = next);
      if (mounted) {
        _showResult(
          context,
          'Mascot illustrations ${next ? 'enabled' : 'disabled'}'
          '${Platform.isAndroid ? ' (mocked on Android)' : ''}',
        );
      }
    } catch (e) {
      if (mounted) _showResult(context, 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _toggle,
      child: Text(
        _shouldShow ? 'Hide mascot illustrations' : 'Show mascot illustrations',
      ),
    );
  }

  void _showResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
