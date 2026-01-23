part of '_interface.dart';

/// Base native method invocation definitions.
///
abstract mixin class IaBaseMethods {
  /// Specified name identifier for the [_channel] object.
  ///
  static const _channelId = 'de.ihreapotheken/sdk';

  /// Static instance of a [MethodChannel] object shared with all of the subclass instances.
  ///
  static final _channel = const MethodChannel(_channelId);

  /// [MethodChannel] class property used for integration with native methods.
  ///
  MethodChannel get channel {
    return _channel;
  }

  /// String identifier for the method forwarded to native logic processing executors.
  ///
  String get methodId;

  /// The defined argument type forwarded to the [invoke] method.
  ///
  Type? get argumentType;

  /// Native method invocation definition and handling.
  ///
  Future<T?> invoke<T>([dynamic args]) async {
    if (argumentType != null && args.runtimeType != argumentType!) {
      throw Exception('Argument type not properly defined for $this. Expected $argumentType, got ${args.runtimeType}.');
    }
    if (args is IaBaseRequest) {
      args = args.toSupportedType();
    }
    return await channel.invokeMethod(methodId, args);
  }
}
