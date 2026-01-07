import 'package:flutter/services.dart';

/// Singleton class providing access to the IA SDK method channel.
///
/// This allows all modules to communicate with the native platform code
/// through a shared channel instance.
///
class IaSdkChannel {
  IaSdkChannel._();

  static final IaSdkChannel _instance = IaSdkChannel._();

  /// Returns the singleton instance of [IaSdkChannel].
  ///
  static IaSdkChannel get instance => _instance;

  /// The method channel for communication with native platform code.
  ///
  final MethodChannel channel = const MethodChannel('de.ihreapotheken/sdk');
}
