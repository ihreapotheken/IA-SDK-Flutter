import 'package:appsdkv2_flutter_plugin_demo/sdk/config.dart';
import 'package:flutter/services.dart';

part 'methods.dart';

/// Base definitions for the ia.de SDK service,
/// including any relevant methods, fields, and callbacks.
///
class IaSdk {
  /// Constructs an instance of the [IaSdk] object using the provided [configuration].
  ///
  IaSdk({
    required IaSdkConfiguration configuration,
  }) : _config = configuration;

  /// Client configuration specification.
  ///
  final IaSdkConfiguration _config;

  /// Instantiate ia.de SDK runtime configuration.
  ///
  /// This method must be invoked before accessing any of the available resources.
  ///
  Future<void> init() async {
    await _IaSdkPlatformMethods.initIaSdk.invoke<void>(
      _config.toJson(),
    );
  }
}
