import 'dart:io';

import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';
import 'package:ia_example_demo/src/actions.dart';
import 'package:ia_example_demo/src/testing/event_log.dart';
import 'package:ia_example_shared/ia_example_shared.dart';
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
    return IaTabListView(
      children: [
        IaSection(
          title: 'Presentation',
          children: [
            IaChoiceRow(
              title: 'Opened by',
              options: const [
                (value: _ScreensMode.auto, label: 'Auto'),
                (value: _ScreensMode.manual, label: 'Manual'),
              ],
              selected: _mode,
              onSelected: (mode) => setState(() => _mode = mode),
              note: switch (_mode) {
                _ScreensMode.auto => 'The SDK presents and dismisses the screens, opened with the plugin\'s launch methods.',
                _ScreensMode.manual =>
                  'The app embeds the screens with IaSdkPlatformView, then pushes or presents them and closes them itself.',
              },
            ),
          ],
        ),
        ...switch (_mode) {
          _ScreensMode.auto => _autoSections(context),
          _ScreensMode.manual => [const _ManualScreensSection()],
        },
      ],
    );
  }

  /// Opens SDK screens with the plugin's launch methods, so the SDK presents them itself.
  ///
  static List<Widget> _autoSections(BuildContext context) {
    final sdk = IaSdk.instance;
    Future<void> launch(Future<void> Function() launch) => runLaunch(context, launch);
    return [
      IaSection(
        title: 'Screens',
        children: [
          IaActionRow(title: 'Start', description: 'The SDK\'s start screen', onTap: () => launch(sdk.launchStartRoute)),
          IaActionRow(title: 'Product Search', onTap: () => launch(sdk.overTheCounter.launchProductSearchRoute)),
          IaActionRow(
            title: 'Product Search, Focused',
            platform: IaPlatform.ios,
            onTap: () => launch(() => sdk.overTheCounter.launchProductSearchRoute(focusesOnAppear: true)),
          ),
          IaActionRow(title: 'Cart', onTap: () => launch(sdk.ordering.launchCartScreen)),
          IaActionRow(title: 'Pharmacy Details', onTap: () => launch(sdk.pharmacy.launchPharmacyDetails)),
          IaActionRow(title: 'Apofinder', onTap: () => launch(sdk.launchApofinder)),
          IaActionRow(
            title: 'Apofinder, Not Cancellable',
            platform: IaPlatform.ios,
            onTap: () => launch(() => sdk.launchApofinder(isCancellable: false)),
          ),
          IaActionRow(title: 'Redeem Prescription', onTap: () => launch(sdk.prescription.launchRedeemPrescriptionScreen)),
        ],
      ),
      if (Platform.isIOS)
        IaSection(
          title: 'Scanners',
          children: [
            IaActionRow(
              title: 'Prescription Photo Scanner',
              platform: IaPlatform.ios,
              onTap: () => launch(() => sdk.prescription.launchPrescriptionScanner(IaPrescriptionScannerType.prescription)),
            ),
            IaActionRow(
              title: 'E-Prescription Scanner',
              platform: IaPlatform.ios,
              onTap: () => launch(() => sdk.prescription.launchPrescriptionScanner(IaPrescriptionScannerType.ePrescription)),
            ),
            IaActionRow(
              title: 'Scanner Camera Test',
              description: 'Opens the photo scanner, then switches the flashlight and pauses the preview',
              platform: IaPlatform.ios,
              onTap: () => launch(_runScannerCameraTest),
            ),
          ],
        ),
      IaSection(
        title: 'Flows',
        children: [
          IaActionRow(
            title: 'Prerequisite Flow',
            description: 'Legal documents, onboarding and pharmacy',
            onTap: () => _launchPrerequisiteFlow(context),
          ),
          IaActionRow(
            title: 'Finish All Activities Test',
            description: 'Opens product search, closes it after 4s. Run only if prerequisites finished before.',
            onTap: _runFinishAllActivitiesTest,
          ),
        ],
      ),
    ];
  }

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
        if (context.mounted) showIaToast(context, 'Prerequisites are already completed');
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
}

/// Builds an SDK screen widget for a route, with the route's embed style and a callback that closes it.
///
typedef _ScreenBuilder = IaSdkScreenView Function(IaSdkScreenEmbedStyle embedStyle, VoidCallback onDismiss);

/// Embeds SDK screens with their [IaSdkScreenView] widgets in a route the app pushes or presents, the way a host app
/// would.
///
class _ManualScreensSection extends StatelessWidget {
  const _ManualScreensSection();

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
    return IaSection(
      title: 'Embedded screens',
      children: [
        for (final MapEntry(key: name, value: builder) in _screens.entries)
          IaBlock(
            padding: const EdgeInsets.fromLTRB(IaSpacing.lg, IaSpacing.md, IaSpacing.md, IaSpacing.md),
            child: Row(
              spacing: IaSpacing.sm,
              children: [
                Expanded(child: Text(name, style: IaTextStyles.headline.copyWith(fontSize: 15))),
                IaButton(
                  title: 'Push',
                  variant: IaButtonVariant.secondary,
                  isCompact: true,
                  onTap: () => _open(context, builder, isPresented: false),
                ),
                IaButton(
                  title: 'Present',
                  variant: IaButtonVariant.secondary,
                  isCompact: true,
                  onTap: () => _open(context, builder, isPresented: true),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
