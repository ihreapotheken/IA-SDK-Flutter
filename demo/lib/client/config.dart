import 'package:appsdkv2_flutter_plugin_demo/sdk/config.dart';
import 'package:flutter/material.dart';

/// Example client app ia.de SDK configuration.
///
/// Includes logic for retrieving of any relevant configuration information.
///
class ExampleAppConfig {
  const ExampleAppConfig._();

  /// Globally-accessible singleton class instance.
  ///
  static final instance = ExampleAppConfig._();

  /// Access key data provided with the CLI commands:
  ///
  /// ```dart
  /// flutter run --dart-define iaAccessKey=myKey
  /// ```
  ///
  final _accessKey = const String.fromEnvironment('iaAccessKey');

  /// Access key used to authenticate with the ia.de backend services.
  ///
  String get accessKey {
    if (_accessKey.isEmpty) {
      return 'e9f3d6a12c4b8f75d1e0a93c5b7d6e2f3c1a9b8e7f4d2c0a1b6e5d3f8c7a1b9e';
    }
    return _accessKey;
  }

  /// Server environment data provided with the CLI commands:
  ///
  /// ```dart
  /// flutter run --dart-define iaServerEnv=staging
  /// ```
  ///
  final _serverEnvironment = const String.fromEnvironment('iaServerEnv');

  /// Specified ia.de SDK server environment.
  ///
  IaSdkConfigServerEnvironment get serverEnvironment {
    try {
      return IaSdkConfigServerEnvironment.values.firstWhere(
        (serverEnv) {
          return serverEnv.name == _serverEnvironment;
        },
      );
    } catch (e) {
      debugPrint('Server environment string not defined from CLI.');
      return IaSdkConfigServerEnvironment.staging;
    }
  }

  /// Specified client identifier with the pharmacy specification service.
  ///
  String get clientId {
    return switch (serverEnvironment) {
      IaSdkConfigServerEnvironment.production => '2004',
      IaSdkConfigServerEnvironment.staging => '5004',
      IaSdkConfigServerEnvironment.development => '103',
    };
  }

  /// Getter method for providing an instance of the plugin [IaSdkConfiguration] object.
  ///
  IaSdkConfiguration get pluginConfig {
    return IaSdkConfiguration(
      accessKey: accessKey,
      clientId: clientId,
      serverEnvironment: serverEnvironment,
    );
  }
}
