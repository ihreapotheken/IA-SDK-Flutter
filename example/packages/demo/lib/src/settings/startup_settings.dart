import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Demo settings the SDK reads only when it initializes, switched in the Services tab.
///
/// They're cached with shared_preferences and applied from the next app start, see [load]. Cached values survive app
/// updates until they're reset with [clear].
///
@immutable
class ExampleStartupSettings {
  const ExampleStartupSettings({
    this.serverEnvironment,
    this.shouldShowMascotIllustrations = true,
    this.isImprintHandledByHostApp = false,
    this.isPickupLockerAndCourierShippingEnabled = false,
    this.deliveryQuickFilter = IaSdkApofinderDeliveryQuickFilter.delivery,
    this.isDeliveryQuickFilterPreselected = false,
    this.appStoreId,
    this.playStoreId,
    this.isAnalyticsEnabled,
    this.isCrashReportingEnabled = true,
  });

  /// The ia.de backend. `null` uses the one the app was built for, see [buildServerEnvironment].
  ///
  final IaSdkConfigurationServerEnvironment? serverEnvironment;

  /// Whether the Pharmi mascot illustrations are rendered. Android reads it only at initialization, while iOS can also
  /// change it at runtime with `setShouldShowMascotIllustrations`.
  ///
  final bool shouldShowMascotIllustrations;

  /// Whether the host app shows the imprint (Android), so the imprint button reports `IaSdkNavigationTarget.imprint`
  /// instead of the SDK opening its own page.
  ///
  final bool isImprintHandledByHostApp;

  /// Whether checkout offers pickup lockers and courier shipping, and Apofinder the "Versand" filter.
  ///
  final bool isPickupLockerAndCourierShippingEnabled;

  /// Apofinder's delivery quick filter. "Versand" needs [isPickupLockerAndCourierShippingEnabled].
  ///
  final IaSdkApofinderDeliveryQuickFilter deliveryQuickFilter;

  /// Whether the delivery quick filter is selected when Apofinder opens.
  ///
  final bool isDeliveryQuickFilterPreselected;

  /// App Store identifier the SDK links to (iOS), for example for update prompts.
  ///
  final String? appStoreId;

  /// Google Play identifier the SDK links to (Android), for example for update prompts.
  ///
  final String? playStoreId;

  /// Whether the SDK tracks analytics events (Android). `null` turns it on outside production.
  ///
  final bool? isAnalyticsEnabled;

  /// Whether the SDK reports its own crashes (Android).
  ///
  final bool isCrashReportingEnabled;

  /// The backend the app was built for, passed as `--dart-define iaServerEnv=…` by the deploy scripts, which also put
  /// it in the launcher label. Staging without it.
  ///
  static IaSdkConfigurationServerEnvironment get buildServerEnvironment {
    return IaSdkConfigurationServerEnvironment.values.asNameMap()[const String.fromEnvironment('iaServerEnv')] ??
        IaSdkConfigurationServerEnvironment.staging;
  }

  /// [serverEnvironment], or [buildServerEnvironment] when it isn't set.
  ///
  IaSdkConfigurationServerEnvironment get effectiveServerEnvironment => serverEnvironment ?? buildServerEnvironment;

  /// [isAnalyticsEnabled], or on outside production when it isn't set.
  ///
  bool get effectiveIsAnalyticsEnabled {
    return isAnalyticsEnabled ?? effectiveServerEnvironment != IaSdkConfigurationServerEnvironment.production;
  }

  /// Copies the settings with the given values. Nullable settings take a function, so they can be set to `null`.
  ///
  ExampleStartupSettings copyWith({
    ValueGetter<IaSdkConfigurationServerEnvironment?>? serverEnvironment,
    bool? shouldShowMascotIllustrations,
    bool? isImprintHandledByHostApp,
    bool? isPickupLockerAndCourierShippingEnabled,
    IaSdkApofinderDeliveryQuickFilter? deliveryQuickFilter,
    bool? isDeliveryQuickFilterPreselected,
    ValueGetter<String?>? appStoreId,
    ValueGetter<String?>? playStoreId,
    ValueGetter<bool?>? isAnalyticsEnabled,
    bool? isCrashReportingEnabled,
  }) {
    return ExampleStartupSettings(
      serverEnvironment: serverEnvironment != null ? serverEnvironment() : this.serverEnvironment,
      shouldShowMascotIllustrations: shouldShowMascotIllustrations ?? this.shouldShowMascotIllustrations,
      isImprintHandledByHostApp: isImprintHandledByHostApp ?? this.isImprintHandledByHostApp,
      isPickupLockerAndCourierShippingEnabled: isPickupLockerAndCourierShippingEnabled ?? this.isPickupLockerAndCourierShippingEnabled,
      deliveryQuickFilter: deliveryQuickFilter ?? this.deliveryQuickFilter,
      isDeliveryQuickFilterPreselected: isDeliveryQuickFilterPreselected ?? this.isDeliveryQuickFilterPreselected,
      appStoreId: appStoreId != null ? appStoreId() : this.appStoreId,
      playStoreId: playStoreId != null ? playStoreId() : this.playStoreId,
      isAnalyticsEnabled: isAnalyticsEnabled != null ? isAnalyticsEnabled() : this.isAnalyticsEnabled,
      isCrashReportingEnabled: isCrashReportingEnabled ?? this.isCrashReportingEnabled,
    );
  }

  static const _serverEnvironmentKey = 'serverEnvironment';
  static const _mascotKey = 'showMascotIllustrations';
  static const _hostImprintKey = 'imprintHandledByHostApp';
  static const _pickupLockerKey = 'pickupLockerAndCourierShipping';
  static const _quickFilterKey = 'apofinderQuickFilter';
  static const _quickFilterPreselectedKey = 'apofinderQuickFilterPreselected';
  static const _appStoreIdKey = 'appStoreId';
  static const _playStoreIdKey = 'playStoreId';
  static const _analyticsKey = 'analyticsEnabled';
  static const _crashReportingKey = 'crashReportingEnabled';

  static const _keys = {
    _serverEnvironmentKey,
    _mascotKey,
    _hostImprintKey,
    _pickupLockerKey,
    _quickFilterKey,
    _quickFilterPreselectedKey,
    _appStoreIdKey,
    _playStoreIdKey,
    _analyticsKey,
    _crashReportingKey,
  };

  /// Reads the cached settings. Settings that were never changed keep their defaults.
  ///
  static Future<ExampleStartupSettings> load() async {
    final values = await SharedPreferencesAsync().getAll(allowList: _keys);
    const defaults = ExampleStartupSettings();
    return ExampleStartupSettings(
      serverEnvironment: IaSdkConfigurationServerEnvironment.values.asNameMap()[values[_serverEnvironmentKey]],
      shouldShowMascotIllustrations: values[_mascotKey] as bool? ?? defaults.shouldShowMascotIllustrations,
      isImprintHandledByHostApp: values[_hostImprintKey] as bool? ?? defaults.isImprintHandledByHostApp,
      isPickupLockerAndCourierShippingEnabled: values[_pickupLockerKey] as bool? ?? defaults.isPickupLockerAndCourierShippingEnabled,
      deliveryQuickFilter: IaSdkApofinderDeliveryQuickFilter.values.asNameMap()[values[_quickFilterKey]] ?? defaults.deliveryQuickFilter,
      isDeliveryQuickFilterPreselected: values[_quickFilterPreselectedKey] as bool? ?? defaults.isDeliveryQuickFilterPreselected,
      appStoreId: values[_appStoreIdKey] as String?,
      playStoreId: values[_playStoreIdKey] as String?,
      isAnalyticsEnabled: values[_analyticsKey] as bool?,
      isCrashReportingEnabled: values[_crashReportingKey] as bool? ?? defaults.isCrashReportingEnabled,
    );
  }

  /// Caches the settings for the next app start. The running SDK keeps the ones it was initialized with.
  ///
  Future<void> save() async {
    final preferences = SharedPreferencesAsync();
    Future<void> setString(String key, String? value) {
      return value == null ? preferences.remove(key) : preferences.setString(key, value);
    }

    await setString(_serverEnvironmentKey, serverEnvironment?.name);
    await preferences.setBool(_mascotKey, shouldShowMascotIllustrations);
    await preferences.setBool(_hostImprintKey, isImprintHandledByHostApp);
    await preferences.setBool(_pickupLockerKey, isPickupLockerAndCourierShippingEnabled);
    await preferences.setString(_quickFilterKey, deliveryQuickFilter.name);
    await preferences.setBool(_quickFilterPreselectedKey, isDeliveryQuickFilterPreselected);
    await setString(_appStoreIdKey, appStoreId);
    await setString(_playStoreIdKey, playStoreId);
    final isAnalyticsEnabled = this.isAnalyticsEnabled;
    await (isAnalyticsEnabled == null ? preferences.remove(_analyticsKey) : preferences.setBool(_analyticsKey, isAnalyticsEnabled));
    await preferences.setBool(_crashReportingKey, isCrashReportingEnabled);
  }

  /// Removes every cached setting, so the next app start uses the defaults.
  ///
  static Future<void> clear() => SharedPreferencesAsync().clear(allowList: _keys);
}
