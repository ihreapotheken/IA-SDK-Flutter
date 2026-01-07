import 'package:flutter/foundation.dart';

/// Utility class for validating method channel argument inputs.
///
class ArgumentValidator {
  /// Verifies that the provided [arguments] match the expected [argumentType] and [requiredMapFields].
  ///
  /// Throws an [Exception] if validation fails.
  ///
  static void verify(
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
}
