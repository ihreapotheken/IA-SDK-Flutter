part of '../../core.dart';

/// Log message written by the SDK, reported through [IaSdk.logMessageListener].
///
class IaSdkLogMessage {
  /// Constructs a new instance of the [IaSdkLogMessage] object.
  ///
  const IaSdkLogMessage({
    required this.message,
    required this.level,
  });

  /// Logged text.
  ///
  final String message;

  /// Name of the log level: `debug`, `info`, `warning`, `error`, `userInteraction`, `cameraError`,
  /// `httpClientInfo`, `httpClientSuccess` or `httpClientError`. Levels added in newer SDK versions are reported by
  /// their SDK title.
  ///
  final String level;
}
