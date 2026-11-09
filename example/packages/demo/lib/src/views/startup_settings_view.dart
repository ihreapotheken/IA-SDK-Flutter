import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';
import 'package:ia_example_demo/ia_client_config.dart';
import 'package:ia_example_demo/src/settings/startup_settings.dart';

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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Setting not saved: $e')));
      }
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
    final textTheme = Theme.of(context).textTheme;
    final isVersandWithoutCourierShipping =
        settings.deliveryQuickFilter == IaSdkApofinderDeliveryQuickFilter.courierShipping &&
        !settings.isPickupLockerAndCourierShippingEnabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Startup Settings', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'The SDK reads these when it initializes. A change is saved and the app closes; it applies when the app is '
          'opened again.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Text('Server environment', style: textTheme.bodyMedium),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<IaSdkConfigurationServerEnvironment>(
            segments: [
              for (final environment in IaSdkConfigurationServerEnvironment.values)
                ButtonSegment(value: environment, label: Text(_serverEnvironmentLabel(environment))),
            ],
            selected: {settings.effectiveServerEnvironment},
            onSelectionChanged: (selection) => _update(context, settings.copyWith(serverEnvironment: () => selection.first)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Built for ${_serverEnvironmentLabel(ExampleStartupSettings.buildServerEnvironment)}, which the launcher '
          'label shows.',
          style: textTheme.bodySmall,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Pickup lockers and courier shipping'),
          subtitle: const Text('Offered in checkout, and "Versand" in Apofinder'),
          value: settings.isPickupLockerAndCourierShippingEnabled,
          onChanged: (value) => _update(context, settings.copyWith(isPickupLockerAndCourierShippingEnabled: value)),
        ),
        Text('Apofinder delivery quick filter', style: textTheme.bodyMedium),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<IaSdkApofinderDeliveryQuickFilter>(
            segments: const [
              ButtonSegment(value: IaSdkApofinderDeliveryQuickFilter.delivery, label: Text('Botendienst')),
              ButtonSegment(value: IaSdkApofinderDeliveryQuickFilter.courierShipping, label: Text('Versand')),
            ],
            selected: {settings.deliveryQuickFilter},
            onSelectionChanged: (selection) => _update(context, settings.copyWith(deliveryQuickFilter: selection.first)),
          ),
        ),
        if (isVersandWithoutCourierShipping) ...[
          const SizedBox(height: 4),
          Text(
            '"Versand" needs pickup lockers and courier shipping. Without them Apofinder shows "Botendienst".',
            style: textTheme.bodySmall,
          ),
        ],
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Quick filter preselected'),
          subtitle: const Text('Selected when Apofinder opens'),
          value: settings.isDeliveryQuickFilterPreselected,
          onChanged: (value) => _update(context, settings.copyWith(isDeliveryQuickFilterPreselected: value)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Mascot illustrations'),
          subtitle: const Text('Pharmi on the CardLink FAQ screen and others'),
          value: settings.shouldShowMascotIllustrations,
          onChanged: (value) => _update(context, settings.copyWith(shouldShowMascotIllustrations: value)),
        ),
        if (Platform.isAndroid) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Host app handles the imprint (Android)'),
            subtitle: const Text('The imprint button reports the imprint navigation target'),
            value: settings.isImprintHandledByHostApp,
            onChanged: (value) => _update(context, settings.copyWith(isImprintHandledByHostApp: value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Analytics (Android)'),
            subtitle: Text(
              settings.isAnalyticsEnabled == null
                  ? 'Default: on outside production. Events show in the Events tab after consent'
                  : 'Events show in the Events tab after consent',
            ),
            value: settings.effectiveIsAnalyticsEnabled,
            onChanged: (value) => _update(context, settings.copyWith(isAnalyticsEnabled: () => value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Crash reporting (Android)'),
            subtitle: const Text('The SDK reports its own crashes'),
            value: settings.isCrashReportingEnabled,
            onChanged: (value) => _update(context, settings.copyWith(isCrashReportingEnabled: value)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Play Store ID (Android)'),
            subtitle: Text(settings.playStoreId ?? 'Not set'),
            trailing: const Icon(Icons.edit),
            onTap: () => _editStoreId(
              context,
              title: 'Play Store ID',
              value: settings.playStoreId,
              update: (value) => settings.copyWith(playStoreId: () => value),
            ),
          ),
        ],
        if (Platform.isIOS)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('App Store ID (iOS)'),
            subtitle: Text(settings.appStoreId ?? 'Not set'),
            trailing: const Icon(Icons.edit),
            onTap: () => _editStoreId(
              context,
              title: 'App Store ID',
              value: settings.appStoreId,
              update: (value) => settings.copyWith(appStoreId: () => value),
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _saveAndExit(context, ExampleStartupSettings.clear, message: 'All startup settings will be reset.'),
          child: const Text('Reset to Defaults'),
        ),
      ],
    );
  }
}
