import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:ia_example_demo/src/testing/event_log.dart';
import 'package:ia_example_demo/src/views/button_label.dart';
import 'package:flutter/material.dart';
import 'package:ia_ordering/ia_ordering.dart';
import 'package:ia_over_the_counter/ia_over_the_counter.dart';
import 'package:ia_pharmacy/ia_pharmacy.dart';
import 'package:ia_prescription/ia_prescription.dart';

/// How the Screens tab opens SDK screens.
///
enum _ScreensMode {
  /// The SDK presents the screen itself, through the plugin's launch methods.
  auto,

  /// The app embeds the screen in its own route with its [IaSdkScreenView] widget.
  manual,
}

class ScreensView extends StatefulWidget {
  const ScreensView({super.key});

  @override
  State<ScreensView> createState() => _ScreensViewState();
}

class _ScreensViewState extends State<ScreensView> {
  _ScreensMode _mode = _ScreensMode.auto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 16 + MediaQuery.of(context).padding.top, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<_ScreensMode>(
                  segments: const [
                    ButtonSegment(value: _ScreensMode.auto, label: Text('Auto')),
                    ButtonSegment(value: _ScreensMode.manual, label: Text('Manual')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) => setState(() => _mode = selection.first),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                switch (_mode) {
                  _ScreensMode.auto => 'The SDK presents and dismisses the screens, opened with the plugin\'s launch methods.',
                  _ScreensMode.manual =>
                    'The app embeds the screens with IaSdkPlatformView, then pushes or presents them and closes them itself.',
                },
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (_mode) {
            _ScreensMode.auto => const _AutoScreensList(),
            _ScreensMode.manual => const _ManualScreensList(),
          },
        ),
      ],
    );
  }
}

/// Opens SDK screens with the plugin's launch methods, so the SDK presents them itself.
///
class _AutoScreensList extends StatelessWidget {
  const _AutoScreensList();

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

  static Future<void> _launchPrerequisiteFlow(BuildContext context) async {
    final log = ExampleEventLog.instance;
    try {
      // Without this check the button seems to do nothing, as the flow finishes without showing a screen.
      if (await IaSdk.instance.isPrerequisiteFlowCompleted()) {
        log.add('Prerequisites', 'Already completed');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prerequisites are already completed')),
          );
        }
        return;
      }
    } catch (e) {
      log.add('Prerequisites', 'Completion check failed: $e');
    }
    try {
      final result = await IaSdk.instance.launchPrerequisiteFlow();
      log.add('Prerequisites', 'cancelled: ${result.isCancelled}');
    } catch (e) {
      log.add('Prerequisites', 'Failed: $e');
    }
  }

  /// Opens product search, then closes the SDK screens after a few seconds. Screens the app presented itself stay.
  static Future<void> _runFinishAllActivitiesTest() async {
    final log = ExampleEventLog.instance;
    await IaSdk.instance.overTheCounter.launchProductSearchRoute();
    await Future<void>.delayed(const Duration(seconds: 4));
    try {
      await IaSdk.instance.finishAllActivities();
      log.add('Finish all activities test', 'SDK screens closed');
    } catch (e) {
      log.add('Finish all activities test', 'Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Launch Product Search, focused (iOS)'),
            onPressed: () => IaSdk.instance.overTheCounter.launchProductSearchRoute(focusesOnAppear: true),
          ),
          const SizedBox(height: 16),
        ],
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
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Launch Apofinder, not cancellable (iOS)'),
            onPressed: () => IaSdk.instance.launchApofinder(isCancellable: false),
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton(
          child: Text('Launch Redeem Prescription'),
          onPressed: () => IaSdk.instance.prescription.launchRedeemPrescriptionScreen(),
        ),
        const SizedBox(height: 16),
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Launch Prescription Photo Scanner (iOS)'),
            onPressed: () => IaSdk.instance.prescription.launchPrescriptionScanner(
              IaPrescriptionScannerType.prescription,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Launch E-Prescription Scanner (iOS)'),
            onPressed: () => IaSdk.instance.prescription.launchPrescriptionScanner(
              IaPrescriptionScannerType.ePrescription,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (Platform.isIOS) ...[
          ElevatedButton(
            child: Text('Scanner Camera Test (iOS)'),
            onPressed: _runScannerCameraTest,
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton(
          child: Text('Launch Prerequisite Flow'),
          onPressed: () => _launchPrerequisiteFlow(context),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: ButtonLabel(
            title: 'Finish All Activities Test',
            description: 'Opens product search, closes it after 4s. Run only if prerequisites finished before.',
          ),
          onPressed: _runFinishAllActivitiesTest,
        ),
      ],
    );
  }
}

/// Builds an SDK screen widget for a route, with the route's embed style and a callback that closes it.
///
typedef _ScreenBuilder = IaSdkScreenView Function(IaSdkScreenEmbedStyle embedStyle, VoidCallback onDismiss);

/// Embeds SDK screens with their [IaSdkScreenView] widgets in a route the app pushes or presents, the way a host app
/// would.
///
class _ManualScreensList extends StatelessWidget {
  const _ManualScreensList();

  /// The SDK screens a host app can embed, by widget name.
  ///
  static final _screens = <String, _ScreenBuilder>{
    'IaStartScreen': (embedStyle, onDismiss) => IaStartScreen(embedStyle: embedStyle, onDismiss: onDismiss),
    'IaProductSearchScreen': (embedStyle, onDismiss) => IaProductSearchScreen(embedStyle: embedStyle, onDismiss: onDismiss),
    'IaCartScreen': (embedStyle, onDismiss) => IaCartScreen(embedStyle: embedStyle, onDismiss: onDismiss),
    'IaPharmacyScreen': (embedStyle, onDismiss) => IaPharmacyScreen(embedStyle: embedStyle, onDismiss: onDismiss),
    'IaApofinderScreen': (embedStyle, onDismiss) => IaApofinderScreen(embedStyle: embedStyle, onDismiss: onDismiss),
    'IaRedeemPrescriptionScreen': (embedStyle, onDismiss) => IaRedeemPrescriptionScreen(embedStyle: embedStyle, onDismiss: onDismiss),
  };

  /// Opens the screen of [builder] in a new route: pushed onto the app's navigation stack, or presented full screen as
  /// a dialog.
  ///
  /// The SDK screen shows its own navigation bar. It adds a back button, or a close button on iOS when presented, and
  /// asks to close through `onDismiss`, which closes the route.
  ///
  static void _open(BuildContext context, _ScreenBuilder builder, {required bool isPresented}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: isPresented,
        builder: (context) => Scaffold(
          body: builder(
            isPresented ? IaSdkScreenEmbedStyle.presentation : IaSdkScreenEmbedStyle.navigation,
            () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        for (final MapEntry(key: name, value: builder) in _screens.entries) ...[
          Text(name, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: const Text('Push'),
                  onPressed: () => _open(context, builder, isPresented: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  child: const Text('Present'),
                  onPressed: () => _open(context, builder, isPresented: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
