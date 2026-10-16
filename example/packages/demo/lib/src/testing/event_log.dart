import 'package:flutter/foundation.dart';

/// Entry of the [ExampleEventLog].
///
typedef ExampleEvent = ({DateTime time, String source, String message});

/// In-app log of the SDK callbacks and stream events the example app receives.
///
/// Shown in the Events tab, so callbacks can be checked on a device without a debugger.
/// Every entry is also printed with [debugPrint].
///
class ExampleEventLog extends ChangeNotifier {
  ExampleEventLog._();

  static final instance = ExampleEventLog._();

  static const _maxEntries = 500;

  final _entries = <ExampleEvent>[];

  /// Logged events, newest first.
  ///
  List<ExampleEvent> get entries => List.unmodifiable(_entries);

  /// Logs [message] under [source], for example `Navigation` or `CardLink`.
  ///
  void add(String source, String message) {
    debugPrint('Host app: [$source] $message');
    _entries.insert(0, (time: DateTime.now(), source: source, message: message));
    if (_entries.length > _maxEntries) {
      _entries.removeLast();
    }
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
