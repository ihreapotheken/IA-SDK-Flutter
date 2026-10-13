part of '_interface.dart';

/// Object defined for handling callbacks received from native app segment.
///
class IaBaseCallbacks {
  /// Default callback for receiving method calls on a [MethodChannel] object.
  ///
  ///
  /// The first subscriber with a matching handler handles the call. Without one, native receives
  /// "not implemented" and falls back to its default. A failing handler is logged with
  /// [FlutterError.presentError] and rethrown, so native receives the error instead of a silent default.
  /// It isn't passed to [FlutterError.onError], so host crash reporting doesn't record it.
  ///
  Future<dynamic> _methodCallHandler(MethodCall call) async {
    for (final subscriber in _subscribers) {
      for (final handler in subscriber.handlers) {
        if (handler.methodId != call.method) continue;
        try {
          return await handler.handler(call.arguments);
        } catch (exception, stack) {
          FlutterError.presentError(
            FlutterErrorDetails(
              exception: exception,
              stack: stack,
              library: 'ia_interface',
              context: ErrorDescription('while handling the native call ${call.method}'),
            ),
          );
          rethrow;
        }
      }
    }
    throw MissingPluginException(
      'No handler registered for the native call ${call.method}.',
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

  /// Installs the handler of the shared `de.ihreapotheken/sdk` channel.
  ///
  /// Called on the first use of the channel (a method call, screen launch, platform view or module), so native
  /// callbacks reach Dart even when no module was constructed. It needs the Flutter binding, which every channel
  /// use needs anyway.
  ///
  static void _ensureSharedChannelHandler() {
    _instance;
  }
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
