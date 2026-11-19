import 'package:flutter/widgets.dart';
import 'package:ia_example_shared/ia_example_shared.dart';

/// Runs an SDK call for a row or button, then shows the message [call] returns in a toast, or its error. A `null`
/// message shows nothing.
///
Future<void> runAction(BuildContext context, Future<String?> Function() call) async {
  try {
    final message = await call();
    if (message != null && context.mounted) showIaToast(context, message);
  } catch (e) {
    if (context.mounted) showIaToast(context, 'Error: $e');
  }
}

/// Opens an SDK screen, showing only a failure.
///
Future<void> runLaunch(BuildContext context, Future<void> Function() launch) {
  return runAction(context, () async {
    await launch();
    return null;
  });
}
