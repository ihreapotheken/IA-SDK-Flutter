part of '../ia_sdk_callback_manager.dart';

/// Base class definition for native callback handler.
///
abstract class _CallbackHandler {
  /// Callback invocation method implementation.
  ///
  Future<dynamic> handle(
    dynamic arguments,
    IaSdk iaSdk,
  );
}
