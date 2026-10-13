part of '../../core.dart';

class _RequestModelInitConfig extends IaSdkConfiguration implements IaBaseRequest {
  _RequestModelInitConfig({
    required super.accessKey,
    required super.clientId,
    required super.serverEnvironment,
    super.shouldFetchThemeFromRemote,
    super.footer,
    super.initialization,
    super.uiConfiguration,
    super.isPickupLockerAndCourierShippingEnabled,
    super.appStoreId,
    super.playStoreId,
    super.isAnalyticsEnabled,
    super.isHapticFeedbackEnabled,
    super.qaConfiguration,
    super.cardLink,
    super.hostAppLogFilePath,
  });

  factory _RequestModelInitConfig.fromConfig(IaSdkConfiguration config) {
    return _RequestModelInitConfig(
      accessKey: config.accessKey,
      clientId: config.clientId,
      serverEnvironment: config.serverEnvironment,
      shouldFetchThemeFromRemote: config.shouldFetchThemeFromRemote,
      footer: config.footer,
      initialization: config.initialization,
      uiConfiguration: config.uiConfiguration,
      isPickupLockerAndCourierShippingEnabled: config.isPickupLockerAndCourierShippingEnabled,
      appStoreId: config.appStoreId,
      playStoreId: config.playStoreId,
      isAnalyticsEnabled: config.isAnalyticsEnabled,
      isHapticFeedbackEnabled: config.isHapticFeedbackEnabled,
      qaConfiguration: config.qaConfiguration,
      cardLink: config.cardLink,
      hostAppLogFilePath: config.hostAppLogFilePath,
    );
  }

  @override
  Map<String, dynamic> toSupportedType() {
    return toJson();
  }
}
