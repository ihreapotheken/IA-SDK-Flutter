import 'package:appsdk_v2_flutter_plugin/common/entities/ia_sdk_configuration.dart';
import 'package:appsdk_v2_flutter_plugin/sdk.dart';

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
      return 'fa0e9523f1a8b20c2038dc65241af81a3882f6f6a73d987fa2ae92e48e740d36';
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
      return IaSdkConfigServerEnvironment.values.firstWhere((serverEnv) {
        return serverEnv.name == _serverEnvironment;
      });
    } catch (e) {
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
      shouldFetchThemeFromRemote: true,
      footer: IaFooterConfiguration(
        shouldShowDataProcessing: false,
        shouldShowAppSettings: true,
        shouldShowImprint: false,
      ),
      initialization: IaInitializationConfiguration(
        shouldShowIndicator: false,
        prerequisites: IaPrerequisitesConfiguration(
          shouldShowIndicator: true,
          isCancellable: true,
          isAnimated: false,
          runLegalIfNeeded: false,
          runOnboardingIfNeeded: true,
          runApofinderIfNeeded: false,
        ),
      ),
    );
  }

  final mockPngPrescription = '';

  final mockJpgPrescription = '';

  final mockPdfPrescription = '';
}
