import 'dart:convert';
import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:ia_example_demo/ia_client_config.dart';
import 'package:ia_example_demo/src/views/button_label.dart';
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
          child: Text('Get Initialization State'),
          onPressed: () async {
            try {
              final state = await IaSdk.instance.getInitializationState();
              if (context.mounted) _showResult(context, 'Initialization state: ${state.name}');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Get Environment'),
          onPressed: () async {
            try {
              final env = await IaSdk.instance.getEnvironment();
              if (context.mounted) _showResult(context, 'Environment: ${env.name}');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: ButtonLabel(title: 'Reset Prerequisites', description: 'For testing only, restart needed'),
          onPressed: () async {
            try {
              await IaSdk.instance.resetPrerequisites();
              if (context.mounted) _showResult(context, 'Prerequisites reset');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: ButtonLabel(title: 'Reset Legal Disclaimer (iOS)', description: 'Restart needed'),
            onPressed: () async {
              try {
                await IaSdk.instance.resetLegalDisclaimer();
                if (context.mounted) _showResult(context, 'Legal disclaimer reset');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: ButtonLabel(title: 'Mark Onboarding Not Shown (iOS)', description: 'Restart needed'),
            onPressed: () async {
              try {
                await IaSdk.instance.setIsOnboardingShown(isOnboardingShown: false);
                if (context.mounted) _showResult(context, 'Onboarding marked as not shown');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        ElevatedButton(
          child: ButtonLabel(
            title: 'Reset Analytics Consent',
            description: Platform.isIOS ? 'Restart needed' : 'The legal screen asks again',
          ),
          onPressed: () async {
            try {
              await IaSdk.instance.resetAnalyticsConsent();
              if (context.mounted) _showResult(context, 'Analytics consent reset');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        if (Platform.isAndroid) ...[
          ElevatedButton(
            child: Text('Is Prerequisite Flow Completed (Android)'),
            onPressed: () async {
              try {
                final result = await IaSdk.instance.isPrerequisiteFlowCompleted();
                if (context.mounted) _showResult(context, 'isPrerequisiteFlowCompleted: $result');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 24),
        ],
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
        const SizedBox(height: 8),
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Get Pharmacy (iOS)'),
            onPressed: () async {
              try {
                final pharmacy = await IaSdk.instance.pharmacy.getPharmacy();
                if (context.mounted) {
                  _showResult(
                    context,
                    pharmacy == null ? 'No pharmacy selected' : '${pharmacy.name}, ${pharmacy.street}, ${pharmacy.city}',
                  );
                }
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Save Pharmacy ID Without Validation (iOS)'),
            onPressed: () async {
              final pharmacyId = await _promptForText(context, 'Pharmacy ID', initialValue: '2163');
              if (pharmacyId == null) return;
              try {
                await IaSdk.instance.pharmacy.savePharmacyId(pharmacyId);
                if (context.mounted) _showResult(context, 'Pharmacy ID $pharmacyId saved');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        ElevatedButton(
          child: ButtonLabel(title: 'Clear Pharmacy ID', description: 'Restart needed'),
          onPressed: () async {
            try {
              await IaSdk.instance.pharmacy.clearPharmacyId();
              if (context.mounted) _showResult(context, 'Pharmacy ID cleared');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 16),
        const _ApofinderQuickFilterSettings(),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Ordering'),
        const SizedBox(height: 8),
        if (Platform.isIOS) ...[
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
        ],
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Get Cart State (iOS)'),
            onPressed: () async {
              try {
                final cart = await IaSdk.instance.ordering.getCartState();
                if (context.mounted) {
                  _showResult(
                    context,
                    cart == null
                        ? 'Cart is empty'
                        : '${cart.totalAmountInCart} items: '
                              '${cart.products?.map((product) => '${product.pzn} x${product.amount}').join(', ')}',
                  );
                }
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Reload Cart and Emit Update (iOS)'),
            onPressed: () async {
              try {
                await IaSdk.instance.ordering.getCartDetails(allowCached: false, shouldEmitCartUpdate: true);
                if (context.mounted) _showResult(context, 'Cart reloaded, see the Events tab');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        ElevatedButton(
          child: Text('Clear Cart'),
          onPressed: () => IaSdk.instance.ordering.clearCart(),
        ),
        const SizedBox(height: 8),
        if (Platform.isIOS) ...[
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
        ],
        for (final variant in _transferVariants) ...[
          ElevatedButton(
            child: Text(variant.label),
            onPressed: () async {
              try {
                await _transferMockPrescriptions(
                  finishAction: variant.finishAction,
                  showActivityIndicator: variant.showActivityIndicator,
                );
                if (context.mounted) _showResult(context, 'Prescriptions transferred');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 24),
        _SectionHeader(title: 'User'),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Set guest user data'),
          onPressed: () async {
            try {
              await IaSdk.instance.setGuestUserData(
                salutation: 'Herr',
                firstName: 'First',
                lastName: 'Last',
                email: 'email@example.org',
                phoneNumberCountryCode: 49,
                phoneNumberWithoutCountryCode: '432432243',
              );
              if (context.mounted) _showResult(context, 'Guest user data set');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Set billing address'),
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
          child: Text('Set delivery address'),
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
          child: Text('Clear billing and delivery addresses'),
          onPressed: () async {
            try {
              await IaSdk.instance.clearUserBillingAddress();
              await IaSdk.instance.clearUserDeliveryAddress();
              if (context.mounted) _showResult(context, 'Addresses cleared');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        if (Platform.isIOS) ...[
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
        ],
        ElevatedButton(
          child: Text('Logout'),
          onPressed: () async {
            try {
              await IaSdk.instance.logout();
              if (context.mounted) _showResult(context, 'Logged out');
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
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
        if (Platform.isIOS) ...[
          const _MascotIllustrationsToggle(),
          const SizedBox(height: 8),
        ],
        if (Platform.isAndroid)
          for (final isEnabled in [false, true]) ...[
            ElevatedButton(
              child: Text('${isEnabled ? 'Enable' : 'Disable'} Haptic Feedback (Android)'),
              onPressed: () async {
                try {
                  await IaSdk.instance.setHapticFeedbackEnabled(isEnabled: isEnabled);
                  if (context.mounted) _showResult(context, 'Haptic feedback ${isEnabled ? 'enabled' : 'disabled'}');
                } catch (e) {
                  if (context.mounted) _showResult(context, 'Error: $e');
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 24),
        _SectionHeader(title: 'Debugging'),
        const SizedBox(height: 8),
        ElevatedButton(
          child: Text('Present Logs'),
          onPressed: () async {
            try {
              await IaSdk.instance.presentLogs();
            } catch (e) {
              if (context.mounted) _showResult(context, 'Error: $e');
            }
          },
        ),
        const SizedBox(height: 8),
        if (Platform.isAndroid) ...[
          ElevatedButton(
            child: Text('Export Logs (Android)'),
            onPressed: () async {
              try {
                final path = await IaSdk.instance.exportLogs();
                if (context.mounted) _showResult(context, 'Logs: $path');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
        ],
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Get User ID (iOS)'),
            onPressed: () async {
              try {
                final userId = await IaSdk.instance.getUserId();
                if (context.mounted) _showResult(context, 'User ID: ${userId ?? 'none'}');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 24),
        ],
        if (Platform.isIOS) ...[
          _SectionHeader(title: 'Cache'),
          const SizedBox(height: 8),
          ElevatedButton(
            child: ButtonLabel(title: 'Clean Cache (iOS)', description: 'For testing only, restart needed'),
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
          const SizedBox(height: 8),
          ElevatedButton(
            child: ButtonLabel(title: 'Remove All Cached Responses (iOS)', description: 'For testing only, restart needed'),
            onPressed: () async {
              try {
                await IaSdk.instance.removeAllCachedResponses();
                if (context.mounted) _showResult(context, 'Cached responses removed');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            child: ButtonLabel(title: 'Clear Product Grid Cache (iOS)', description: 'For testing only, restart needed'),
            onPressed: () async {
              try {
                await IaSdk.instance.overTheCounter.clearProductGridCache();
                if (context.mounted) _showResult(context, 'Product grid cache cleared');
              } catch (e) {
                if (context.mounted) _showResult(context, 'Error: $e');
              }
            },
          ),
        ],
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

  static final _transferVariants = <({String label, IaTransferPrescriptionsFinishAction finishAction, bool showActivityIndicator})>[
    (label: 'Transfer Prescriptions, Open Cart', finishAction: IaTransferPrescriptionsFinishAction.openCart, showActivityIndicator: true),
    (
      label: 'Transfer Prescriptions, Bottom Sheet',
      finishAction: IaTransferPrescriptionsFinishAction.showBottomSheet,
      showActivityIndicator: true,
    ),
    if (Platform.isIOS)
      (
        label: 'Transfer Prescriptions, No Action or Indicator (iOS)',
        finishAction: IaTransferPrescriptionsFinishAction.noAction,
        showActivityIndicator: false,
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

/// Apofinder's delivery quick filter, "Botendienst" or "Versand", and whether it's preselected.
///
/// The SDK reads these settings only when it initializes, so a change is cached with
/// [ExampleAppConfig.cacheApofinder] and the app offers to close, to apply it on the next start.
///
class _ApofinderQuickFilterSettings extends StatefulWidget {
  const _ApofinderQuickFilterSettings();

  @override
  State<_ApofinderQuickFilterSettings> createState() => _ApofinderQuickFilterSettingsState();
}

class _ApofinderQuickFilterSettingsState extends State<_ApofinderQuickFilterSettings> {
  /// The cached settings, starting with the ones the SDK was initialized with.
  ///
  IaSdkConfigurationApofinder _settings = ExampleAppConfig.instance.apofinder;

  /// Whether the cached settings differ from the ones the SDK was initialized with.
  ///
  bool get _isRestartNeeded {
    final active = ExampleAppConfig.instance.apofinder;
    return _settings.deliveryQuickFilter != active.deliveryQuickFilter ||
        _settings.isDeliveryQuickFilterPreselected != active.isDeliveryQuickFilterPreselected;
  }

  Future<void> _update({
    IaSdkApofinderDeliveryQuickFilter? deliveryQuickFilter,
    bool? isDeliveryQuickFilterPreselected,
  }) async {
    final previous = _settings;
    final settings = IaSdkConfigurationApofinder(
      deliveryQuickFilter: deliveryQuickFilter ?? previous.deliveryQuickFilter,
      isDeliveryQuickFilterPreselected: isDeliveryQuickFilterPreselected ?? previous.isDeliveryQuickFilterPreselected,
    );
    setState(() => _settings = settings);
    try {
      await ExampleAppConfig.instance.cacheApofinder(settings);
    } catch (e) {
      if (!mounted) return;
      setState(() => _settings = previous);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Setting not saved: $e')));
      return;
    }
    // Switched back to the settings the SDK runs with, nothing to apply.
    if (!mounted || !_isRestartNeeded) return;
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restart needed'),
          content: const Text(
            'The setting is saved. The SDK reads it only when it initializes, so it applies the next time the app '
            'starts.\n\nClose the app now?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Later')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Close App')),
          ],
        );
      },
    );
    if (shouldClose ?? false) exit(0);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPickupLockerMissing =
        _settings.deliveryQuickFilter == IaSdkApofinderDeliveryQuickFilter.courierShipping &&
        ExampleAppConfig.instance.isPickupLockerAndCourierShippingEnabled != true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Apofinder delivery quick filter', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<IaSdkApofinderDeliveryQuickFilter>(
            segments: const [
              ButtonSegment(value: IaSdkApofinderDeliveryQuickFilter.delivery, label: Text('Botendienst')),
              ButtonSegment(value: IaSdkApofinderDeliveryQuickFilter.courierShipping, label: Text('Versand')),
            ],
            selected: {_settings.deliveryQuickFilter},
            onSelectionChanged: (selection) => _update(deliveryQuickFilter: selection.first),
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Preselected'),
          subtitle: const Text('The quick filter is selected when Apofinder opens'),
          value: _settings.isDeliveryQuickFilterPreselected,
          onChanged: (value) => _update(isDeliveryQuickFilterPreselected: value),
        ),
        if (isPickupLockerMissing)
          Text(
            '"Versand" needs --dart-define iaPickupLocker=true. Without it Apofinder shows "Botendienst".',
            style: textTheme.bodySmall,
          ),
        if (_isRestartNeeded) Text('Applies after a restart', style: textTheme.bodySmall),
      ],
    );
  }
}

/// Runtime toggle for the Pharmi mascot illustrations.
///
/// The mascot renders on the CardLink FAQ screen, so flip this and then open
/// CardLink → Launch CardLink → FAQ to see the change. Screens already on
/// screen keep the value they were built with.
///
/// iOS only: Android's native UI configuration is immutable after init, so the
/// mascot is set there through [IaUIConfiguration.shouldShowMascotIllustrations]
/// in [ExampleAppConfig.pluginConfig] instead.
class _MascotIllustrationsToggle extends StatefulWidget {
  const _MascotIllustrationsToggle();

  @override
  State<_MascotIllustrationsToggle> createState() {
    return _MascotIllustrationsToggleState();
  }
}

class _MascotIllustrationsToggleState extends State<_MascotIllustrationsToggle> {
  /// Seeded from the value the SDK was initialized with, so the button label
  /// starts out reflecting the SDK's actual state.
  bool _shouldShow = ExampleAppConfig.instance.pluginConfig.uiConfiguration.shouldShowMascotIllustrations;

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
          'Mascot illustrations ${next ? 'enabled' : 'disabled'}. '
          'Open CardLink → FAQ to see the change.',
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
        _shouldShow ? 'Hide mascot illustrations (iOS)' : 'Show mascot illustrations (iOS)',
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
