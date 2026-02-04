part of '_interface.dart';

/// Object defined for handling callbacks received from native app segment.
///
class IaBaseCallbacks {
  /// Default callback for receiving method calls on a [MethodChannel] object.
  ///
  Future<dynamic> _methodCallHandler(MethodCall call) async {
    for (final subscriber in _subscribers) {
      try {
        final matchingCallback = subscriber.handlers.firstWhere(
          (handler) {
            return handler.methodId == call.method;
          },
        );
        return await matchingCallback.handler(call.arguments);
      } catch (e) {
        continue;
      }
    }
    throw Exception(
      'No method call ${call.method} found.',
    );
  }

  /// Constructs a new instance of the callback handler class,
  /// adding a subscriber instance to the static [_subscribers] collection.
  ///
  IaBaseCallbacks({
    this.channel,
    required this.handlers,
  }) {
    if (channel != null) {
      channel!.setMethodCallHandler(_methodCallHandler);
    }
    for (final subscriber in _subscribers) {
      for (final handler in handlers) {
        if (subscriber.handlers.where(
          (subscriberHandler) {
            return subscriberHandler.methodId == handler.methodId;
          },
        ).isNotEmpty) {
          debugPrint('Duplicate handler method found: ${handler.methodId}.');
        }
      }
    }
    _subscribers.add(this);
  }

  /// Collection of subscribers used for receiving callbacks.
  ///
  static final _subscribers = <IaBaseCallbacks>[];

  /// Custom channel specified for callback integration.
  ///
  final MethodChannel? channel;

  /// Callback handler forwarded to the
  ///
  final List<IaBaseCallbackHandler> handlers;

  /// Unnamed constructor defining default call handler properties.
  ///
  IaBaseCallbacks._() : channel = null, handlers = const [] {
    IaBaseMethods._channel.setMethodCallHandler(_methodCallHandler);
  }

  /// Singleton instance used for allocating unnamed constructor resources.
  ///
  static final _instance = IaBaseCallbacks._();
}

/// Handler method used in conjunction with [IaBaseCallbacks].
///
/// Defines the handling of the callback received from the native platform.
///
abstract class IaBaseCallbackHandler {
  /// Callback method identifier forwarded from the native module.
  ///
  String get methodId;

  /// Callback method handler processed with Flutter.
  ///
  Future<dynamic> Function(dynamic args) get handler;
}
