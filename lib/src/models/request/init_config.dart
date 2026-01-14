part of '../../core.dart';

class _RequestModelInitConfig extends IaSdkConfiguration implements IaBaseRequest {
  _RequestModelInitConfig({
    required super.accessKey,
    required super.clientId,
    required super.serverEnvironment,
    super.shouldFetchThemeFromRemote,
    super.footer,
    super.initialization,
  });

  factory _RequestModelInitConfig.fromConfig(IaSdkConfiguration config) {
    return _RequestModelInitConfig(
      accessKey: config.accessKey,
      clientId: config.clientId,
      serverEnvironment: config.serverEnvironment,
      shouldFetchThemeFromRemote: config.shouldFetchThemeFromRemote,
      footer: config.footer,
      initialization: config.initialization,
    );
  }

  @override
  Map<String, dynamic> toSupportedType() {
    return toJson();
  }
}
