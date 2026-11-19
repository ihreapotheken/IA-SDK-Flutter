import 'package:flutter/material.dart';
import 'package:ia_example_demo/src/testing/event_log.dart';
import 'package:ia_example_demo/src/testing/test_settings.dart';
import 'package:ia_example_shared/ia_example_shared.dart';

/// Shows the SDK callbacks and events the example app received, and switches how the app answers them.
///
class EventsView extends StatelessWidget {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ExampleEventLog.instance, ExampleEventLog.analytics, ExampleTestSettings.instance]),
      builder: (context, _) {
        final settings = ExampleTestSettings.instance;
        return IaTabListView(
          children: [
            IaSection(
              title: 'Host answers',
              children: [
                IaSwitchRow(
                  title: 'Host handles navigation targets',
                  description: 'The SDK doesn\'t open the screen, e.g. the cart',
                  value: settings.handlesNavigation,
                  onChanged: (value) => settings.handlesNavigation = value,
                ),
                IaSwitchRow(
                  title: 'Block the back action',
                  description: 'SDK screens stay open on system back',
                  platform: IaPlatform.android,
                  value: settings.blocksBackAction,
                  onChanged: (value) => settings.blocksBackAction = value,
                ),
                IaSwitchRow(
                  title: 'Log SDK messages',
                  description: 'Adds the SDK\'s own log messages below',
                  platform: IaPlatform.ios,
                  value: settings.logsSdkMessages,
                  onChanged: (value) => settings.logsSdkMessages = value,
                ),
                IaChoiceRow(
                  title: 'Prescription scan answer',
                  options: [for (final decision in ExampleScanDecision.values) (value: decision, label: decision.name)],
                  selected: settings.scanDecision,
                  onSelected: (decision) => settings.scanDecision = decision,
                ),
              ],
            ),
            _LogSection(
              title: 'Analytics',
              log: ExampleEventLog.analytics,
              emptyText: 'No analytics events yet. They need analytics enabled for the SDK and the user\'s consent.',
            ),
            _LogSection(
              title: 'Events',
              log: ExampleEventLog.instance,
              emptyText: 'No events yet. Use the SDK screens, then come back.',
            ),
          ],
        );
      },
    );
  }
}

/// A log's entries, newest first, with a button that clears them.
///
class _LogSection extends StatelessWidget {
  const _LogSection({required this.title, required this.log, required this.emptyText});

  final String title;
  final ExampleEventLog log;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final entries = log.entries;
    return IaSection(
      title: '$title (${entries.length})',
      trailing: IaLinkButton(title: 'Clear', onTap: entries.isEmpty ? null : log.clear),
      children: [
        IaBlock(
          child: entries.isEmpty
              ? Text(emptyText, style: IaTextStyles.caption.copyWith(color: IaColors.inkTertiary))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: IaSpacing.md,
                  children: [
                    for (final entry in entries)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: '${_time(entry.time)}  ',
                              children: [
                                TextSpan(
                                  text: entry.source,
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: IaColors.accentOnSoft),
                                ),
                              ],
                            ),
                            style: IaTextStyles.mono.copyWith(color: IaColors.inkTertiary),
                          ),
                          Text(entry.message, style: IaTextStyles.mono.copyWith(color: IaColors.ink)),
                        ],
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  static String _time(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';
  }
}
