import 'dart:io';

import 'package:ia_example_demo/src/testing/event_log.dart';
import 'package:ia_example_demo/src/testing/test_settings.dart';
import 'package:flutter/material.dart';

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
        return ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            24 + MediaQuery.of(context).padding.top,
            20,
            24,
          ),
          children: [
            Text('Host Answers', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Host handles navigation targets'),
              subtitle: const Text('The SDK doesn\'t open the screen, e.g. the cart'),
              value: settings.handlesNavigation,
              onChanged: (value) => settings.handlesNavigation = value,
            ),
            if (Platform.isAndroid)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Block the back action (Android)'),
                subtitle: const Text('SDK screens stay open on system back'),
                value: settings.blocksBackAction,
                onChanged: (value) => settings.blocksBackAction = value,
              ),
            if (Platform.isIOS)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Log SDK messages (iOS)'),
                subtitle: const Text('Adds the SDK\'s own log messages below'),
                value: settings.logsSdkMessages,
                onChanged: (value) => settings.logsSdkMessages = value,
              ),
            const SizedBox(height: 8),
            Text('Prescription scan answer', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            SegmentedButton<ExampleScanDecision>(
              segments: [
                for (final decision in ExampleScanDecision.values) ButtonSegment(value: decision, label: Text(decision.name)),
              ],
              selected: {settings.scanDecision},
              onSelectionChanged: (selection) => settings.scanDecision = selection.first,
            ),
            const SizedBox(height: 24),
            ..._section(
              context,
              title: 'Analytics',
              log: ExampleEventLog.analytics,
              emptyText: 'No analytics events yet. They need analytics enabled for the SDK and the user\'s consent.',
            ),
            const SizedBox(height: 24),
            ..._section(
              context,
              title: 'Events',
              log: ExampleEventLog.instance,
              emptyText: 'No events yet. Use the SDK screens, then come back.',
            ),
          ],
        );
      },
    );
  }

  static List<Widget> _section(
    BuildContext context, {
    required String title,
    required ExampleEventLog log,
    required String emptyText,
  }) {
    final entries = log.entries;
    return [
      Row(
        children: [
          Expanded(
            child: Text(
              '$title (${entries.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: entries.isEmpty ? null : log.clear,
            child: const Text('Clear'),
          ),
        ],
      ),
      if (entries.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(emptyText),
        ),
      for (final entry in entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_time(entry.time)}  ${entry.source}  ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: entry.message),
              ],
            ),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
    ];
  }

  static String _time(DateTime time) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}';
  }
}
