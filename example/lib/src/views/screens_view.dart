import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/testing/event_log.dart';
import 'package:flutter/material.dart';

/// How the Screens tab opens SDK screens.
///
enum _ScreensMode {
  /// The SDK presents the screen itself, through the plugin's launch methods.
  auto,

  /// The app embeds the screen in its own route with [IaSdkPlatformView].
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

  static Future<void> _launchPrerequisiteFlow() async {
    final log = ExampleEventLog.instance;
    try {
      final result = await IaSdk.instance.launchPrerequisiteFlow();
      log.add('Prerequisites', 'cancelled: ${result.isCancelled}');
    } catch (e) {
      log.add('Prerequisites', 'Failed: $e');
    }
  }

  /// Opens product search, then closes the SDK screens after a few seconds. Screens the app presented itself stay.
  ///
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
          onPressed: _launchPrerequisiteFlow,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          child: Text('Finish All Activities Test'),
          onPressed: _runFinishAllActivitiesTest,
        ),
      ],
    );
  }
}

/// Embeds SDK screens with [IaSdkPlatformView] in a route the app pushes or presents, the way a host app would.
///
class _ManualScreensList extends StatelessWidget {
  const _ManualScreensList();

  /// Platform view ids each platform registers for SDK screens.
  ///
  static List<String> get _viewIds => [
    'startScreen',
    'searchScreen',
    'cartScreen',
    'pharmacyScreen',
    'apofinderScreen',
    'redeemPrescription',
    if (Platform.isIOS) ...['prescriptionScanner', 'ePrescriptionScanner'],
    if (Platform.isAndroid) ...['prerequisiteFlow', 'transferPrescriptionsScreen'],
  ];

  /// Opens [viewId] in a new route: pushed onto the app's navigation stack, or presented full screen as a dialog.
  ///
  /// The SDK screen shows its own navigation bar. On iOS it adds a back or close button and reports its tap, which
  /// closes the route; on Android the system back action closes it.
  ///
  static void _open(BuildContext context, String viewId, {required bool isPresented}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: isPresented,
        builder: (context) => Scaffold(
          body: IaSdkPlatformView(
            viewId: viewId,
            selfSizing: false,
            embedStyle: isPresented ? IaSdkScreenEmbedStyle.presentation : IaSdkScreenEmbedStyle.navigation,
            onDismiss: () => Navigator.of(context).pop(),
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
        for (final viewId in _viewIds) ...[
          Text(viewId, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: const Text('Push'),
                  onPressed: () => _open(context, viewId, isPresented: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  child: const Text('Present'),
                  onPressed: () => _open(context, viewId, isPresented: true),
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
