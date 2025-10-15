part of 'sdk.dart';

/// Collection of method identifiers specified for client integration.
///
enum _IaSdkPlatformMethods {
  /// Used to allocate ia.de SDK resources.
  ///
  /// Must be invoked before any of the available SDK methods or fields are utilised.
  ///
  /// Corresponds to:
  ///
  /// - iOS `IASDK.initialize`
  /// - Android `IaSdk.register.init`
  ///
  initIaSdk,

  startComposeActivity;

  /// Creates a [MethodChannel] with the specified [name].
  ///
  /// Used for communication with the native ia.de library integration.
  ///
  final _platformChannel = const MethodChannel('de.ihreapotheken/sdk');

  /// Verifies [_platformChannel] argument input.
  ///
  void _verifyArgumentInput(
    dynamic arguments, {
    required Type? argumentType,
    List<({String name, Type type, bool nullable})>? requiredMapFields,
  }) {
    if (argumentType == null) return;
    final exception = Exception(
      'Argument ${arguments.runtimeType} is not of type $argumentType:\n$arguments',
    );
    switch (argumentType) {
      case const (String):
        if (arguments is! String) throw exception;
        break;
      case const (bool):
        if (arguments is! bool) throw exception;
        break;
      case const (int):
        if (arguments is! int) throw exception;
        break;
      case const (double):
        if (arguments is! double) throw exception;
        break;
      case const (Uint8List):
        if (arguments is! Uint8List) throw exception;
        break;
      case const (Map):
        if (arguments is! Map) throw exception;
        if (requiredMapFields == null) {
          throw Exception(
            'Required map fields must be provided for verification.',
          );
        }
        for (final requiredField in requiredMapFields) {
          final value = arguments[requiredField.name];
          if (value == null && !requiredField.nullable) {
            throw Exception(
              'Field ${requiredField.name} must be submitted with '
              'argument declaration:\n---\n$requiredField',
            );
          }
        }
        break;
      default:
        throw Exception(
          'Argument type $argumentType not implemented.',
        );
    }
  }

  /// Invokes any specified native method using a [MethodChannel] object, returning the result.
  ///
  Future<T?> invoke<T>(
    dynamic arguments,
  ) async {
    try {
      switch (this) {
        case _IaSdkPlatformMethods.initIaSdk:
          _verifyArgumentInput(
            arguments,
            argumentType: Map,
            requiredMapFields: [
              (
                name: 'accessKey',
                type: String,
                nullable: false,
              ),
              (
                name: 'clientId',
                type: String,
                nullable: false,
              ),
              (
                name: 'serverEnvironment',
                type: String,
                nullable: false,
              ),
            ],
          );
          return await _platformChannel.invokeMethod(
            name,
            arguments,
          );
        case _IaSdkPlatformMethods.startComposeActivity:
          if (Platform.isAndroid) {
            return await _platformChannel.invokeMethod(
              name,
              null,
            );
          }
          return null;
      }
    } catch (e) {
      throw Exception(
        'An error occurred invoking the $name method with:\n---\n$arguments\n---\n$e',
      );
    }
  }
}
