import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';
import 'package:ia_example_demo/ia_client_config.dart';
import 'package:ia_example_demo/src/settings/startup_settings.dart';
import 'package:ia_example_shared/ia_example_shared.dart';

/// Switches the settings the SDK reads only when it initializes, see [ExampleStartupSettings].
///
/// Every change first warns that the setting is saved and the app closes. Accepting caches it and exits the app, so
/// the next start applies it; cancelling changes nothing. The controls show the settings the app runs with.
///
class StartupSettingsSection extends StatelessWidget {
  const StartupSettingsSection({super.key});

  static ExampleStartupSettings get _settings => ExampleAppConfig.instance.startupSettings;

  /// Warns that the app closes, then runs [save] and exits the app when the user accepts.
  ///
  static Future<void> _saveAndExit(BuildContext context, Future<void> Function() save, {required String message}) async {
    final isAccepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restart needed'),
          content: Text('$message\n\nThe SDK reads this only when it starts, so the app will close. Open it again to apply it.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Save and Close')),
          ],
        );
      },
    );
    if (isAccepted != true) return;
    try {
      await save();
    } catch (e) {
      if (context.mounted) showIaToast(context, 'Setting not saved: $e');
      return;
    }
    exit(0);
  }

  static Future<void> _update(BuildContext context, ExampleStartupSettings settings) {
    return _saveAndExit(context, settings.save, message: 'The setting will be saved.');
  }

  /// Asks for a store identifier, then saves it with [update]. An empty value removes it.
  ///
  static Future<void> _editStoreId(
    BuildContext context, {
    required String title,
    required String? value,
    required ExampleStartupSettings Function(String? value) update,
  }) async {
    final controller = TextEditingController(text: value);
    final entered = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Empty to remove it'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('OK')),
          ],
        );
      },
    ).whenComplete(controller.dispose);
    if (entered == null || !context.mounted) return;
    final newValue = entered.isEmpty ? null : entered;
    if (newValue == value) return;
    await _update(context, update(newValue));
  }

  static String _serverEnvironmentLabel(IaSdkConfigurationServerEnvironment environment) {
    return switch (environment) {
      IaSdkConfigurationServerEnvironment.development => 'DEV',
      IaSdkConfigurationServerEnvironment.staging => 'QA',
      IaSdkConfigurationServerEnvironment.production => 'PROD',
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final isVersandWithoutCourierShipping =
        settings.deliveryQuickFilter == IaSdkApofinderDeliveryQuickFilter.courierShipping &&
        !settings.isPickupLockerAndCourierShippingEnabled;
    return IaSection(
      title: 'Startup settings',
      children: [
        const IaHint(
          'The SDK reads these when it initializes. A change is saved and the app closes; it applies when the app is '
          'opened again.',
        ),
        IaChoiceRow(
          title: 'Server environment',
          options: [
            for (final environment in IaSdkConfigurationServerEnvironment.values)
              (value: environment, label: _serverEnvironmentLabel(environment)),
          ],
          selected: settings.effectiveServerEnvironment,
          onSelected: (environment) {
            if (environment == settings.effectiveServerEnvironment) return;
            _update(context, settings.copyWith(serverEnvironment: () => environment));
          },
          note: 'Built for ${_serverEnvironmentLabel(ExampleStartupSettings.buildServerEnvironment)}, which the launcher label shows.',
        ),
        IaSwitchRow(
          title: 'Pickup lockers and courier shipping',
          description: 'Offered in checkout, and "Versand" in Apofinder',
          value: settings.isPickupLockerAndCourierShippingEnabled,
          onChanged: (value) => _update(context, settings.copyWith(isPickupLockerAndCourierShippingEnabled: value)),
        ),
        IaChoiceRow(
          title: 'Apofinder delivery quick filter',
          options: const [
            (value: IaSdkApofinderDeliveryQuickFilter.delivery, label: 'Botendienst'),
            (value: IaSdkApofinderDeliveryQuickFilter.courierShipping, label: 'Versand'),
          ],
          selected: settings.deliveryQuickFilter,
          onSelected: (filter) {
            if (filter == settings.deliveryQuickFilter) return;
            _update(context, settings.copyWith(deliveryQuickFilter: filter));
          },
          note: isVersandWithoutCourierShipping
              ? '"Versand" needs pickup lockers and courier shipping. Without them Apofinder shows "Botendienst".'
              : null,
        ),
        IaSwitchRow(
          title: 'Quick filter preselected',
          description: 'Selected when Apofinder opens',
          value: settings.isDeliveryQuickFilterPreselected,
          onChanged: (value) => _update(context, settings.copyWith(isDeliveryQuickFilterPreselected: value)),
        ),
        IaSwitchRow(
          title: 'Mascot illustrations',
          description: 'Pharmi on the CardLink FAQ screen and others',
          value: settings.shouldShowMascotIllustrations,
          onChanged: (value) => _update(context, settings.copyWith(shouldShowMascotIllustrations: value)),
        ),
        IaSwitchRow(
          title: 'Host app handles the imprint',
          description: 'The imprint button reports the imprint navigation target',
          platform: IaPlatform.android,
          value: settings.isImprintHandledByHostApp,
          onChanged: (value) => _update(context, settings.copyWith(isImprintHandledByHostApp: value)),
        ),
        IaSwitchRow(
          title: 'Analytics',
          description: settings.isAnalyticsEnabled == null
              ? 'Default: on outside production. Events show in the Events tab after consent'
              : 'Events show in the Events tab after consent',
          platform: IaPlatform.android,
          value: settings.effectiveIsAnalyticsEnabled,
          onChanged: (value) => _update(context, settings.copyWith(isAnalyticsEnabled: () => value)),
        ),
        IaSwitchRow(
          title: 'Crash reporting',
          description: 'The SDK reports its own crashes',
          platform: IaPlatform.android,
          value: settings.isCrashReportingEnabled,
          onChanged: (value) => _update(context, settings.copyWith(isCrashReportingEnabled: value)),
        ),
        IaValueRow(
          title: 'Play Store ID',
          value: settings.playStoreId ?? 'Not set',
          platform: IaPlatform.android,
          onTap: () => _editStoreId(
            context,
            title: 'Play Store ID',
            value: settings.playStoreId,
            update: (value) => settings.copyWith(playStoreId: () => value),
          ),
        ),
        IaValueRow(
          title: 'App Store ID',
          value: settings.appStoreId ?? 'Not set',
          platform: IaPlatform.ios,
          onTap: () => _editStoreId(
            context,
            title: 'App Store ID',
            value: settings.appStoreId,
            update: (value) => settings.copyWith(appStoreId: () => value),
          ),
        ),
        IaActionRow(
          title: 'Reset to Defaults',
          description: 'Resets every startup setting',
          // Not awaited: the row would show progress behind the dialog.
          onTap: () {
            _saveAndExit(context, ExampleStartupSettings.clear, message: 'All startup settings will be reset.');
          },
        ),
      ],
    );
  }
}
