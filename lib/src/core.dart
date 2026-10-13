import 'dart:async';
import 'dart:ui' show Color;

import 'package:ia_interface/ia_interface.dart';

part 'common/callbacks.dart';
part 'common/methods.dart';
part 'common/navigation.dart';
part 'common/views.dart';
part 'config/_config.dart';
part 'config/analytics_consent.dart';
part 'config/card_link.dart';
part 'config/footer.dart';
part 'config/initialization.dart';
part 'config/qa.dart';
part 'config/server_environment.dart';
part 'config/ui_configuration.dart';
part 'models/request/analytics_consent.dart';
part 'models/request/guest_user_data.dart';
part 'models/request/init_config.dart';
part 'models/request/register_modules.dart';
part 'models/request/clean_cache.dart';
part 'models/request/set_enabled.dart';
part 'models/request/set_user_address.dart';
part 'models/request/mascot_illustrations.dart';
part 'models/response/analytics_event.dart';
part 'models/response/initialization_state.dart';
part 'models/response/log_message.dart';
part 'models/response/prerequisites_result.dart';

/// Main entrypoint for the ia.de AppSDK services and features.
///
/// Members documented as "Only supported on iOS" or "Only supported on Android" throw a
/// [MissingPluginException] on the other platform.
///
class IaSdk {
  IaSdk._();

  /// Globally-accessible singleton class instance.
  ///
  static final instance = IaSdk._();

  /// Client-facing error message displayed for scenarios where any of the modules have not been registered.
  ///
  Exception _moduleNotInitializedError(IaBaseModule module) {
    return Exception(
      'Module ${module.name} not initalized. '
      'Ensure the object is instantiated and forwarded to the "register" method with the "modules" field.',
    );
  }

  /// Property defining the internal state of the CardLink native module.
  ///
  IaBaseCardLink? _cardLink;

  /// Methods and properties available with the [IaBaseCardLink] native module.
  ///
  IaBaseCardLink get cardLink {
    if (_cardLink == null) {
      throw _moduleNotInitializedError(IaBaseModule.cardLink);
    }
    return _cardLink!;
  }

  /// Property defining the internal state of the Ordering native module.
  ///
  IaBaseOrdering? _ordering;

  /// Methods and properties available with the [IaBaseOrdering] native module.
  ///
  IaBaseOrdering get ordering {
    if (_ordering == null) {
      throw _moduleNotInitializedError(IaBaseModule.ordering);
    }
    return _ordering!;
  }

  /// Property defining the internal state of the OverTheCounter native module.
  ///
  IaBaseOverTheCounter? _overTheCounter;

  /// Methods and properties available with the [IaBaseOverTheCounter] native module.
  ///
  IaBaseOverTheCounter get overTheCounter {
    if (_overTheCounter == null) {
      throw _moduleNotInitializedError(IaBaseModule.overTheCounter);
    }
    return _overTheCounter!;
  }

  /// Property defining the internal state of the Pharmacy native module.
  ///
  IaBasePharmacy? _pharmacy;

  /// Methods and properties available with the [IaBasePharmacy] native module.
  ///
  IaBasePharmacy get pharmacy {
    if (_pharmacy == null) {
      throw _moduleNotInitializedError(IaBaseModule.pharmacyDetails);
    }
    return _pharmacy!;
  }

  /// Property defining the internal state of the Prescription native module.
  ///
  IaBasePrescription? _prescription;

  /// Methods and properties available with the [IaBasePrescription] native module.
  ///
  IaBasePrescription get prescription {
    if (_prescription == null) {
      throw _moduleNotInitializedError(IaBaseModule.prescription);
    }
    return _prescription!;
  }

  /// Determines whether the user had forwarded the required data to the [register] method.
  ///
  bool _modulesRegistered = false;

  /// Register a collection of specified [modules] for client integration.
  ///
  /// Modules provide specific functionality to client integrations,
  /// and are available after registering with the following [IaSdk.instance] getter methods:
  ///
  /// - [cardLink]
  /// - [ordering]
  /// - [overTheCounter]
  /// - [pharmacy]
  /// - [prescription]
  ///
  Future<void> register({
    required List<IaBase> modules,
  }) async {
    if (!_modulesRegistered) {
      final arguments = _RequestModelRegisterModules(
        modules: modules.map(
          (moduleEntry) {
            return moduleEntry.module;
          },
        ).toList(),
      );
      return await _Methods.register.invoke(arguments).then((value) {
        for (final module in modules) {
          for (final internalModule
              in <
                ({
                  IaBaseModule type,
                  Function(dynamic value) setProperty,
                })
              >{
                (
                  type: IaBaseModule.cardLink,
                  setProperty: (value) => _cardLink = value,
                ),
                (
                  type: IaBaseModule.ordering,
                  setProperty: (value) => _ordering = value,
                ),
                (
                  type: IaBaseModule.overTheCounter,
                  setProperty: (value) => _overTheCounter = value,
                ),
                (
                  type: IaBaseModule.pharmacyDetails,
                  setProperty: (value) => _pharmacy = value,
                ),
                (
                  type: IaBaseModule.prescription,
                  setProperty: (value) => _prescription = value,
                ),
              }) {
            if (module.module == internalModule.type) {
              internalModule.setProperty(module);
            }
          }
        }
        _modulesRegistered = true;
        return value;
      });
    }
  }

  /// Determines whether the [initialize] method had been successfully invoked.
  ///
  bool _initialized = false;

  /// Allocates the resources required for the AppSDK usage.
  ///
  Future<void> initialize({
    required IaSdkConfiguration config,
  }) async {
    if (!_initialized) {
      final arguments = _RequestModelInitConfig.fromConfig(config);
      await _Methods.initialize.invoke(arguments);
      _initialized = true;
      // Android only attaches the host log file to CardLink, so the CardLink module forwards it there.
      final hostAppLogFilePath = config.hostAppLogFilePath;
      if (hostAppLogFilePath != null) {
        await _cardLink?.setHostAppLogFilePath(hostAppLogFilePath);
      }
    }
  }

  /// Forwards the client personal information to the ia.de library for checkout purposes.
  ///
  /// [salutation] is one of "Herr", "Frau", "Divers" (or "Diverse") and "Keine Angabe", matched case-insensitively.
  /// Other values are rejected with an `ARG_ERROR`.
  ///
  /// The phone number is passed as an `int`, so leading zeros of [phoneNumberWithoutCountryCode] are lost.
  ///
  Future<void> setGuestUserData({
    required String salutation,
    required String firstName,
    required String lastName,
    required String email,
    required int phoneNumberCountryCode,
    required int phoneNumberWithoutCountryCode,
  }) async {
    final arguments = _RequestModelSetGuestUserData(
      salutation: salutation,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumberCountryCode: phoneNumberCountryCode,
      phoneNumberWithoutCountryCode: phoneNumberWithoutCountryCode,
    );
    return await _Methods.setGuestUserData.invoke(arguments);
  }

  /// Resets the user data and onboarding status (pharmacy selection, user consents statuses).
  ///
  Future<void> logout() async {
    return await _Methods.logout.invoke();
  }

  /// Resets the prerequisites state, so the SDK runs the prerequisites flow
  /// (legal documents, onboarding) again the next time it's required.
  ///
  /// Unlike [logout], user data is kept.
  ///
  Future<void> resetPrerequisites() async {
    return await _Methods.resetPrerequisites.invoke();
  }

  /// Resets only the accepted legal documents, so the user is asked to accept them again.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> resetLegalDisclaimer() async {
    return await _Methods.resetLegalDisclaimer.invoke();
  }

  /// Marks the onboarding as shown or not shown, which decides whether the prerequisites flow shows it.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> setIsOnboardingShown(bool isOnboardingShown) async {
    final arguments = _RequestModelSetEnabled(
      enabled: isOnboardingShown,
    );
    return await _Methods.setIsOnboardingShown.invoke(arguments);
  }

  /// Returns `true` if the user has completed the prerequisites flow (legal documents, onboarding).
  ///
  /// Note: Only supported on Android.
  ///
  Future<bool> isPrerequisiteFlowCompleted() async {
    final result = await _Methods.isPrerequisiteFlowCompleted.invoke<bool>();
    return result ?? false;
  }

  /// Launches the prerequisites flow (legal documents, onboarding) on top of the navigation stack.
  ///
  /// The outcome is reported through [prerequisitesResultListener].
  ///
  /// Note: Only supported on Android. On iOS the prerequisites run automatically when an SDK screen needs them.
  ///
  Future<void> launchPrerequisiteFlow() async {
    return await _Views.prerequisiteFlow.launch();
  }

  /// Launches the start screen experience on top of the navigation stack.
  ///
  Future<void> launchStartRoute() async {
    return await _Views.startScreen.launch();
  }

  /// Launches the Apofinder (pharmacy finder) screen on top of the navigation stack.
  ///
  /// The selected pharmacy is reported through [onApofinderDidChangePharmacy].
  ///
  /// [isCancellable] decides whether the user can close Apofinder without selecting a pharmacy. It's only used on iOS.
  ///
  Future<void> launchApofinder({
    bool isCancellable = true,
  }) async {
    return await _Views.apofinderScreen.launch(
      arguments: {
        'isCancellable': isCancellable,
      },
    );
  }

  /// Closes any overlaying ia.de screen contents.
  ///
  Future<void> finishAllActivities() async {
    return await _Methods.finishAllActivities.invoke();
  }

  /// Transfers user data from SDK v1 to the current SDK.
  ///
  /// The method is intended to be invoked before the [initialize] method.
  ///
  Future<void> transferSDKv1UserData() async {
    return await _Methods.transferSDKv1UserData.invoke();
  }

  /// Legacy setup required when the host app is the Core app.
  ///
  /// Note: Only has an effect on iOS.
  ///
  Future<void> legacySetupAsCoreApp() async {
    return await _Methods.legacySetupAsCoreApp.invoke();
  }

  /// Returns `true` if the SDK has been successfully initialized.
  ///
  Future<bool> isInitialized() async {
    final result = await _Methods.isInitialized.invoke<bool>();
    return result ?? false;
  }

  /// Deletes the user account from the SDK.
  ///
  /// This is different from [logout] which clears local data — this deletes the user on the backend.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> deleteUser() async {
    return await _Methods.deleteUser.invoke();
  }

  /// Returns the current server environment.
  ///
  Future<IaSdkConfigurationServerEnvironment?> getEnvironment() async {
    final result = await _Methods.getEnvironment.invoke<String?>();
    if (result == null) return null;
    return IaSdkConfigurationServerEnvironment.values.where((e) => e.name == result).firstOrNull;
  }

  /// Toggles the Pharmi mascot illustrations at runtime.
  ///
  /// Updates the same value as [IaUIConfiguration.shouldShowMascotIllustrations],
  /// which is only read while the SDK initializes. Use this to change the setting
  /// on an already-initialized SDK — screens rendered after the call pick up the
  /// new value.
  ///
  /// Note: Only supported on iOS. The Android AppSDK's UI configuration is an
  /// immutable value supplied at initialization, so there is nothing to update
  /// at runtime — configure the mascot through
  /// [IaUIConfiguration.shouldShowMascotIllustrations] instead, which both
  /// platforms honour.
  ///
  Future<void> setShouldShowMascotIllustrations({
    required bool shouldShowMascotIllustrations,
  }) async {
    final arguments = _RequestModelSetShouldShowMascotIllustrations(
      shouldShowMascotIllustrations: shouldShowMascotIllustrations,
    );
    return await _Methods.setShouldShowMascotIllustrations.invoke(arguments);
  }

  /// Clears cached SDK data for initialization and/or prerequisites.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> cleanCache({
    bool initialization = false,
    bool prerequisites = false,
  }) async {
    final arguments = _RequestModelCleanCache(
      initialization: initialization,
      prerequisites: prerequisites,
    );
    return await _Methods.cleanCache.invoke(arguments);
  }

  /// Sets the user's billing address, used to pre-fill the checkout flow.
  ///
  /// Pass a salutation matching the values accepted by [setGuestUserData]
  /// (for example "Herr"/"Frau") or `null` to leave it unset.
  ///
  /// The phone number is only stored when both [phoneNumberCountryCode] and [phoneNumberWithoutCountryCode] are set.
  ///
  Future<void> setUserBillingAddress({
    required String firstName,
    required String lastName,
    String? additionalInfo,
    required String street,
    required String houseNumber,
    required String zipCode,
    required String city,
    String? salutation,
    int? phoneNumberCountryCode,
    String? phoneNumberWithoutCountryCode,
  }) async {
    final arguments = _RequestModelSetUserAddress(
      firstName: firstName,
      lastName: lastName,
      additionalInfo: additionalInfo,
      street: street,
      houseNumber: houseNumber,
      zipCode: zipCode,
      city: city,
      salutation: salutation,
      phoneNumberCountryCode: phoneNumberCountryCode,
      phoneNumberWithoutCountryCode: phoneNumberWithoutCountryCode,
    );
    return await _Methods.setUserBillingAddress.invoke(arguments);
  }

  /// Sets the user's delivery address, used to pre-fill the checkout flow.
  ///
  /// Pass a salutation matching the values accepted by [setGuestUserData]
  /// (for example "Herr"/"Frau") or `null` to leave it unset.
  ///
  /// The phone number is only stored when both [phoneNumberCountryCode] and [phoneNumberWithoutCountryCode] are set.
  ///
  Future<void> setUserDeliveryAddress({
    required String firstName,
    required String lastName,
    String? additionalInfo,
    required String street,
    required String houseNumber,
    required String zipCode,
    required String city,
    String? salutation,
    int? phoneNumberCountryCode,
    String? phoneNumberWithoutCountryCode,
  }) async {
    final arguments = _RequestModelSetUserAddress(
      firstName: firstName,
      lastName: lastName,
      additionalInfo: additionalInfo,
      street: street,
      houseNumber: houseNumber,
      zipCode: zipCode,
      city: city,
      salutation: salutation,
      phoneNumberCountryCode: phoneNumberCountryCode,
      phoneNumberWithoutCountryCode: phoneNumberWithoutCountryCode,
    );
    return await _Methods.setUserDeliveryAddress.invoke(arguments);
  }

  /// Removes the billing address set with [setUserBillingAddress].
  ///
  Future<void> clearUserBillingAddress() async {
    return await _Methods.clearUserBillingAddress.invoke();
  }

  /// Removes the delivery address set with [setUserDeliveryAddress].
  ///
  Future<void> clearUserDeliveryAddress() async {
    return await _Methods.clearUserDeliveryAddress.invoke();
  }

  /// Sets the user's consent for the SDK's analytics tracking.
  ///
  /// Call it after [initialize]. Tracking also needs [IaSdkConfiguration.isAnalyticsEnabled].
  ///
  /// Note: Only supported on Android.
  ///
  Future<void> setAnalyticsConsent(IaSdkAnalyticsConsent consent) async {
    final arguments = _RequestModelSetAnalyticsConsent(
      consent: consent,
    );
    return await _Methods.setAnalyticsConsent.invoke(arguments);
  }

  /// Turns haptic feedback in SDK screens on or off.
  ///
  /// Note: Only supported on Android.
  ///
  Future<void> setHapticFeedbackEnabled(bool isEnabled) async {
    final arguments = _RequestModelSetEnabled(
      enabled: isEnabled,
    );
    return await _Methods.setHapticFeedbackEnabled.invoke(arguments);
  }

  /// Presents the SDK's log viewer, for debugging an integration.
  ///
  Future<void> presentLogs() async {
    return await _Methods.presentLogs.invoke();
  }

  /// Writes the SDK's logs to a file and returns its path, or `null` if there are no logs.
  ///
  /// Note: Only supported on Android. On iOS the log viewer opened with [presentLogs] can share the logs.
  ///
  Future<String?> exportLogs() async {
    return await _Methods.exportLogs.invoke<String?>();
  }

  /// Returns the SDK's identifier for the current user, for example to include in support requests.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<String?> getUserId() async {
    return await _Methods.getUserId.invoke<String?>();
  }

  /// Removes all cached network responses of the SDK, for testing an integration with fresh data.
  ///
  /// Note: Only supported on iOS. See [cleanCache] for the initialization and prerequisites caches.
  ///
  Future<void> removeAllCachedResponses() async {
    return await _Methods.removeAllCachedResponses.invoke();
  }

  /// Property holding internal state of the native callback handlers.
  ///
  // ignore: unused_field
  final _callbackHandlers = IaBaseCallbacks(
    handlers: [
      const _NavigationHandler(),
      const _ApofinderPharmacyChangedHandler(),
      const _InitializationStateHandler(),
      const _AnalyticsEventHandler(),
      const _LogMessageHandler(),
      const _BackActionHandler(),
      const _PrerequisitesResultHandler(),
    ],
  );

  /// Called when the user leaves an SDK screen opened from the host app with the system back action.
  ///
  /// Return `true` to close the screen, `false` to keep it open. When not set, the screen closes.
  ///
  /// It isn't called for the prerequisites flow opened with [launchPrerequisiteFlow], whose SDK screen has no
  /// back hook.
  ///
  /// Note: Only supported on Android.
  ///
  Future<bool> Function()? onSdkBackAction;

  /// Notifier object informing the client integration of the outcome of the prerequisites flow
  /// (onboarding, legal documents, pharmacy selection).
  ///
  /// On iOS it reports every completed prerequisites run, on Android the runs started with [launchPrerequisiteFlow].
  ///
  final prerequisitesResultListener = StreamController<IaSdkPrerequisitesResult>.broadcast();

  /// Notifier object informing the client integration of SDK initialization state changes.
  ///
  /// Usage:
  ///
  /// ```dart
  /// IaSdk.instance.initializationStateListener.stream.listen((state) {
  ///   // Process state.
  /// });
  /// ```
  ///
  final initializationStateListener = StreamController<IaSdkInitializationState>.broadcast();

  /// Notifier object informing the client integration of analytics events tracked by the SDK.
  ///
  /// Events are only tracked with [IaSdkConfiguration.isAnalyticsEnabled] and the user's consent,
  /// see [setAnalyticsConsent].
  ///
  /// Note: Only supported on Android.
  ///
  final analyticsEventListener = StreamController<IaSdkAnalyticsEvent>.broadcast();

  /// Notifier object informing the client integration of messages the SDK logs, for debugging an integration.
  ///
  /// Messages are only forwarded from the native SDK while the stream has listeners.
  ///
  /// Note: Only supported on iOS.
  ///
  late final logMessageListener = StreamController<IaSdkLogMessage>.broadcast(
    onListen: () => _setLogMessageForwardingEnabled(true),
    onCancel: () => _setLogMessageForwardingEnabled(false),
  );

  void _setLogMessageForwardingEnabled(bool isEnabled) {
    final arguments = _RequestModelSetEnabled(
      enabled: isEnabled,
    );
    // Android has no log messages to forward and leaves the call unimplemented.
    _Methods.setLogMessageForwardingEnabled.invoke(arguments).catchError((Object _) => null);
  }

  /// Called when the SDK is about to navigate to a destination that the host app can override.
  ///
  /// For example, if the SDK would present the cart screen contents, the host app can switch to its own contents by returning `false`.
  ///
  /// Return `true` to let the SDK proceed with its built-in presentation.
  ///
  /// On Android the SDK waits at most 500 ms for the answer and otherwise proceeds with its
  /// built-in presentation. A later answer is ignored, so answer without awaiting slow work, or the
  /// host's screen and the SDK's screen both open.
  ///
  /// Usage:
  ///
  /// ```dart
  /// IaSdk.instance.onSdkWillNavigateToTarget = (navigationTarget) async {
  ///   if (navigationTarget == SdkNavigationTarget.cart) {
  ///     // Switch to your own cart tab.
  ///     switchToTab(TabType.cart);
  ///     return false;
  ///   }
  ///   return true;
  /// };
  /// ```
  ///
  Future<bool> Function(
    IaSdkNavigationTarget navigationTarget,
  )?
  onSdkWillNavigateToTarget;

  /// Called when the user changes their pharmacy via the Apofinder flow.
  ///
  /// Provides the new [pharmacyId] and whether the change was triggered from the prerequisites flow.
  ///
  /// Note: On Android only pharmacies selected in the screen opened with [launchApofinder] are reported.
  ///
  void Function({
    required String pharmacyId,
    required bool isFromPrerequisites,
  })?
  onApofinderDidChangePharmacy;
}
