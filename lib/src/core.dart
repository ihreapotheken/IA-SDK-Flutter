import 'dart:async';
import 'dart:convert' show jsonEncode;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'package:ia_interface/ia_interface.dart';

part 'common/callbacks.dart';
part 'common/methods.dart';
part 'common/navigation.dart';
part 'common/views.dart';
part 'config/_config.dart';
part 'config/card_link.dart';
part 'config/footer.dart';
part 'config/initialization.dart';
part 'config/qa.dart';
part 'config/server_environment.dart';
part 'config/ui_configuration.dart';
part 'models/request/guest_user_data.dart';
part 'models/request/init_config.dart';
part 'models/request/register_modules.dart';
part 'models/request/clean_cache.dart';
part 'models/request/set_enabled.dart';
part 'models/request/set_user_address.dart';
part 'models/request/mascot_illustrations.dart';
part 'models/response/analytics_names.dart';
part 'models/response/initialization_state.dart';
part 'models/response/log_message.dart';
part 'models/response/logged_analytics_event.dart';
part 'models/response/prerequisites_result.dart';

/// Main entrypoint for the ia.de AppSDK services and features.
///
/// Methods documented as "Only supported on iOS" or "Only supported on Android" throw a
/// [MissingPluginException] on the other platform. Callbacks and streams with such a note never fire there.
///
/// Failed calls throw a [PlatformException]. Its code is `ARG_ERROR` for invalid arguments, and otherwise names the
/// method, for example `CLEAR_CART_ERROR` for `clearCart`. On Android, calls that need an initialized SDK fail with
/// `SDK_NOT_INITIALIZED` before [initialize], and `transferPrescriptions` and [launchPrerequisiteFlow] fail with
/// `NO_ACTIVITY` without an attached activity. Other screens then open in a new task. CardLink has its own codes, see
/// `IaBaseCardLink`.
///
/// {@category Overview}
/// {@category Initialization}
/// {@category Interaction}
/// {@category StartScreen}
/// {@category ApofinderScreen}
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

  /// Modules passed to the successful [register] call.
  ///
  final _registeredModules = <IaBaseModule>{};

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
  /// Pass all modules in one call, before [initialize]: the Android SDK only starts the modules registered before it
  /// initializes, so a call after [initialize] throws a [StateError]. Later calls have no effect, and throw a
  /// [StateError] when they pass a module the first call didn't. Create the module objects for this call too, as
  /// their native part registers when they're created.
  ///
  /// Fails when a module's native part is missing, for example when the app wasn't rebuilt after adding the module.
  ///
  Future<void> register({
    required List<IaBase> modules,
  }) async {
    // A call made while another one runs waits for it, then counts as a later call. When that one failed, another
    // waiting call may have started meanwhile, so this waits until none runs.
    for (var pending = _pendingRegistration; pending != null; pending = _pendingRegistration) {
      await pending.catchError((Object _) {});
    }
    if (_modulesRegistered) {
      final unregisteredModules = [
        for (final moduleEntry in modules)
          if (!_registeredModules.contains(moduleEntry.module)) moduleEntry.module.name,
      ];
      if (unregisteredModules.isNotEmpty) {
        throw StateError(
          'IaSdk.register was already called, so ${unregisteredModules.join(', ')} can\'t be added. '
          'Pass all modules in the first call.',
        );
      }
      return;
    }
    if (_initialized || _pendingInitialization != null) {
      throw StateError(
        'Call IaSdk.register before initialize: the Android SDK only starts the modules registered before it '
        'initializes.',
      );
    }
    final registration = _register(modules);
    _pendingRegistration = registration;
    try {
      await registration;
    } finally {
      _pendingRegistration = null;
    }
  }

  /// The [register] call in progress, which [initialize] waits for.
  ///
  Future<void>? _pendingRegistration;

  Future<void> _register(List<IaBase> modules) async {
    // Each module starts its native registration when it's created; a missing native part fails here.
    await Future.wait(modules.map((moduleEntry) => moduleEntry.nativeRegistration));
    if (!_modulesRegistered) {
      final arguments = _RequestModelRegisterModules(
        modules: modules.map(
          (moduleEntry) {
            return moduleEntry.module;
          },
        ).toList(),
      );
      return await _Methods.register.invoke(arguments).then((value) async {
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
        _registeredModules.addAll(modules.map((moduleEntry) => moduleEntry.module));
        return value;
      });
    }
  }

  /// Determines whether the [initialize] method had been successfully invoked.
  ///
  bool _initialized = false;

  /// Allocates the resources required for the AppSDK usage.
  ///
  /// Only the first successful call has an effect; later calls return without applying their [config], and a call
  /// made while another one runs completes with it.
  ///
  /// An empty [IaSdkConfiguration.accessKey] or [IaSdkConfiguration.clientId] fails with `ARG_ERROR` before the SDK
  /// starts initializing.
  ///
  /// On iOS, open SDK screens and show inline components after it completed. A screen launched while it runs opens
  /// once it's done, but a screen or component shown before it starts keeps loading.
  ///
  /// On Android the SDK initializes only once. When it can't load the bundle permissions, for example for an invalid
  /// access key, this call fails but the SDK still finishes initializing, so a later call completes without loading
  /// them again. When the initialization itself fails, later calls fail too. On iOS a later call initializes the SDK
  /// again; while an SDK screen runs the initialization and prerequisites itself, the call waits until they're done.
  ///
  Future<void> initialize({
    required IaSdkConfiguration config,
  }) async {
    if (_initialized) return;
    // A call made while another one runs waits for it instead of initializing again. The running call is set before
    // anything is awaited, so a call or a register made meanwhile sees it.
    final pendingInitialization = _pendingInitialization;
    if (pendingInitialization != null) return pendingInitialization;
    final initialization = _initialize(config);
    _pendingInitialization = initialization;
    try {
      await initialization;
    } finally {
      _pendingInitialization = null;
    }
  }

  Future<void>? _pendingInitialization;

  Future<void> _initialize(IaSdkConfiguration config) async {
    // A register call that's still running finishes first, so its modules start. Its failure is its own caller's.
    await _pendingRegistration?.catchError((Object _) {});
    // The Android SDK rejects these without reporting an error state, unlike the iOS SDK, so both fail the same here.
    if (config.accessKey.trim().isEmpty || config.clientId.trim().isEmpty) {
      throw PlatformException(code: 'ARG_ERROR', message: 'accessKey and clientId must not be empty.');
    }
    final arguments = _RequestModelInitConfig.fromConfig(config);
    await _Methods.initialize.invoke(arguments);
    _initialized = true;
    _hostAppLogFilePath = config.hostAppLogFilePath;
    await _forwardHostAppLogFilePath();
  }

  String? _hostAppLogFilePath;

  /// Android only attaches the host log file to CardLink, so [initialize] forwards it to the CardLink module, which
  /// [register] added before. A failure only affects CardLink problem reports, so it doesn't fail [initialize].
  ///
  Future<void> _forwardHostAppLogFilePath() async {
    final hostAppLogFilePath = _hostAppLogFilePath;
    final cardLink = _cardLink;
    if (hostAppLogFilePath == null || cardLink == null) return;
    try {
      await cardLink.setHostAppLogFilePath(hostAppLogFilePath);
    } catch (exception, stack) {
      FlutterError.presentError(
        FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'appsdk_v2_flutter_plugin',
          context: ErrorDescription('while forwarding the host app log file to CardLink'),
        ),
      );
    }
  }

  /// Forwards the client personal information to the ia.de library for checkout purposes.
  ///
  /// [salutation] is one of "Herr", "Frau", "Divers" (or "Diverse") and "Keine Angabe", matched case-insensitively.
  /// Other values are stored as "Keine Angabe".
  ///
  /// On Android, call it after [initialize]; before that the call fails.
  ///
  /// On Android the SDK applies it in the background after the call returns, and doesn't report failures.
  ///

  Future<void> setGuestUserData({
    required String salutation,
    required String firstName,
    required String lastName,
    required String email,
    required int phoneNumberCountryCode,
    required String phoneNumberWithoutCountryCode,
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
  /// On Android, call it after [initialize]; before that the call fails.
  ///
  /// On Android the SDK applies it in the background after the call returns, and doesn't report failures.
  ///

  Future<void> logout() async {
    return await _Methods.logout.invoke();
  }

  /// Resets the prerequisites state, so the SDK runs the prerequisites flow
  /// (legal documents, onboarding, pharmacy selection) again the next time it's required.
  ///
  /// The selected pharmacy is cleared too. Unlike [logout], other user data is kept.
  ///
  /// On Android, call it after [initialize]; before that the call fails.
  ///
  /// On Android the SDK applies it in the background after the call returns, and doesn't report failures.
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

  /// Resets the user's analytics consent answer, so the prerequisites flow asks for it again.
  ///
  /// On Android, call it after [initialize]; before that the call fails.
  ///
  Future<void> resetAnalyticsConsent() async {
    return await _Methods.resetAnalyticsConsent.invoke();
  }

  /// Marks the onboarding as shown or not shown, which decides whether the prerequisites flow shows it.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> setIsOnboardingShown({
    required bool isOnboardingShown,
  }) async {
    final arguments = _RequestModelSetEnabled(
      enabled: isOnboardingShown,
    );
    return await _Methods.setIsOnboardingShown.invoke(arguments);
  }

  /// Returns `true` if the user has completed the prerequisites flow (legal documents, onboarding) and a valid
  /// pharmacy is selected, so [launchPrerequisiteFlow] would finish without showing a screen. Legal documents and
  /// onboarding only count when the prerequisites options passed to [initialize] run them.
  ///
  /// Call it after [initialize]; before that the call fails.
  ///
  /// Note: On Android the pharmacy isn't needed when [IaPrerequisitesConfiguration.runApofinderIfNeeded] is `false`,
  /// and counts as selected when it can't be loaded, for example without network. On iOS it's always needed, and
  /// the call fails when it can't be loaded.
  ///
  Future<bool> isPrerequisiteFlowCompleted() async {
    final result = await _Methods.isPrerequisiteFlowCompleted.invoke<bool>();
    return result ?? false;
  }

  /// Runs the prerequisites flow (legal documents, onboarding, pharmacy selection) on top of the navigation stack, and
  /// returns its result once the user finished or cancelled it.
  ///
  /// Call it after [initialize] has completed, and don't show SDK screens or components until it has returned.
  /// Otherwise SDK screens can run the prerequisites themselves at the same time. The flow uses
  /// [IaSdkConfigurationInitialization.prerequisites] of the configuration passed to [initialize].
  ///
  /// When the prerequisites are already completed, it returns right away without showing anything. A call made while
  /// the flow runs fails with `PREREQUISITE_FLOW_IN_PROGRESS`.
  ///
  /// On Android it fails with `SDK_NOT_INITIALIZED` before [initialize] has succeeded. On iOS it runs the
  /// initialization again first after a failed [initialize].
  ///
  Future<IaSdkPrerequisitesResult> launchPrerequisiteFlow() async {
    if (_isPrerequisiteFlowRunning) {
      throw PlatformException(
        code: 'PREREQUISITE_FLOW_IN_PROGRESS',
        message: 'The prerequisites flow is already running.',
      );
    }
    _isPrerequisiteFlowRunning = true;
    try {
      final result = await _Methods.launchPrerequisiteFlow.invoke<Map>();
      final isCancelled = result?['isCancelled'];
      if (isCancelled is! bool) {
        throw Exception('launchPrerequisiteFlow: Missing or invalid isCancelled: $result.');
      }
      return IaSdkPrerequisitesResult(isCancelled: isCancelled);
    } finally {
      _isPrerequisiteFlowRunning = false;
    }
  }

  bool _isPrerequisiteFlowRunning = false;

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

  /// Closes the ia.de screens shown on top of the app, including screens the SDK opened from them.
  ///
  /// Screens the host app presented itself stay open, and so does a CardLink flow the host launched. On iOS, a CardLink
  /// flow launched while an SDK screen was shown sits on that screen and closes with it, reporting `willExit`.
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

  /// Returns the current initialization state, see also [initializationStateListener].
  ///
  Future<IaSdkInitializationState> getInitializationState() async {
    final result = await _Methods.getInitializationState.invoke<String>();
    return IaSdkInitializationState.values.where((state) => state.name == result).firstOrNull ?? IaSdkInitializationState.uninitialized;
  }

  /// Returns `true` if the SDK has been successfully initialized.
  ///
  Future<bool> isInitialized() async {
    final result = await _Methods.isInitialized.invoke<bool>();
    return result ?? false;
  }

  /// Deletes the user data the SDK stores on the device: the guest and registered user with their name, email,
  /// phone number and addresses.
  ///
  /// It makes no backend request. [logout] deletes this data too, and also resets the prerequisites, the cart and
  /// the pharmacy.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> deleteUser() async {
    return await _Methods.deleteUser.invoke();
  }

  /// Returns the current server environment. Before [initialize] it's the SDK's default, production.
  ///
  Future<IaSdkConfigurationServerEnvironment> getEnvironment() async {
    final result = await _Methods.getEnvironment.invoke<String?>();
    final environment = IaSdkConfigurationServerEnvironment.values.where((e) => e.name == result).firstOrNull;
    if (environment == null) {
      throw StateError('getEnvironment: Unknown environment $result.');
    }
    return environment;
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
  /// With [initialization], the SDK is uninitialized afterwards, and the next [initialize] call initializes it again.
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
    await _Methods.cleanCache.invoke(arguments);
    if (initialization) {
      // The SDK is uninitialized again, so the next [initialize] call has to run.
      _initialized = false;
    }
  }

  /// Sets the user's billing address, used to pre-fill the checkout flow.
  ///
  /// On Android, call it after [initialize]; before that the call fails.
  ///
  /// On Android the SDK applies it in the background after the call returns, and doesn't report failures.
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
  /// On Android, call it after [initialize]; before that the call fails.
  ///
  /// On Android the SDK applies it in the background after the call returns, and doesn't report failures.
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
  /// On Android, call it after [initialize]; before that the call fails.
  ///
  /// On Android the SDK applies it in the background after the call returns, and doesn't report failures.
  ///
  Future<void> clearUserBillingAddress() async {
    return await _Methods.clearUserBillingAddress.invoke();
  }

  /// Removes the delivery address set with [setUserDeliveryAddress].
  ///
  /// On Android, call it after [initialize]; before that the call fails.
  ///
  /// On Android the SDK applies it in the background after the call returns, and doesn't report failures.
  ///
  Future<void> clearUserDeliveryAddress() async {
    return await _Methods.clearUserDeliveryAddress.invoke();
  }

  /// Turns haptic feedback in SDK screens on or off.
  ///
  /// Call it after [initialize]; before that the call fails. [IaSdkConfiguration.isHapticFeedbackEnabled] sets the
  /// initial value.
  ///
  /// Note: Only supported on Android.
  ///
  Future<void> setHapticFeedbackEnabled({
    required bool isEnabled,
  }) async {
    final arguments = _RequestModelSetEnabled(
      enabled: isEnabled,
    );
    return await _Methods.setHapticFeedbackEnabled.invoke(arguments);
  }

  /// Presents the SDK's log viewer, for debugging an integration.
  ///
  /// On Android, call it after [initialize]; before that the call fails.
  ///
  Future<void> presentLogs() async {
    return await _Methods.presentLogs.invoke();
  }

  /// Writes the SDK's logs to a file and returns its path. Fails when the logs can't be exported.
  ///
  /// Call it after [initialize]; before that the call fails.
  ///
  /// Note: Only supported on Android. On iOS the log viewer opened with [presentLogs] can share the logs.
  ///
  Future<String> exportLogs() async {
    final path = await _Methods.exportLogs.invoke<String?>();
    if (path == null) {
      throw StateError('exportLogs: No path returned.');
    }
    return path;
  }

  /// Returns the SDK's identifier for the current user, for example to include in support requests.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<String?> getUserId() async {
    return await _Methods.getUserId.invoke<String?>();
  }

  /// Removes the SDK's cached image responses, for testing an integration with fresh images.
  ///
  /// Cached API data isn't affected. See [cleanCache] for the initialization and prerequisites caches.
  ///
  /// Note: Only supported on iOS.
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
      const _LoggedAnalyticsEventHandler(),
      const _LogMessageHandler(),
      const _BackActionHandler(),
    ],
  );

  /// Called before an SDK screen opened from the host app closes, for example with the system back action or the
  /// SDK's own close buttons.
  ///
  /// Return `true` to close the screen, `false` to keep it open. When not set, when it throws, or when it doesn't
  /// answer within 5 seconds, the screen closes. [finishAllActivities] always closes the screens without asking.
  ///
  /// It isn't called for the prerequisites flow opened with [launchPrerequisiteFlow], whose SDK screen has no
  /// back hook, nor for the screens the SDK opens from `IaProductGrid` or for `transferPrescriptions`, which it
  /// starts without one. The SDK keeps a single back hook for all its screens and removes it when one of them closes,
  /// so after a screen launched on top of another one closes, the screen below closes without asking.
  ///
  /// Note: Only supported on Android.
  ///
  Future<bool> Function()? onSdkBackAction;

  /// Notifier object informing the client integration of SDK initialization state changes.
  ///
  /// Changes that happen before the stream has a listener aren't replayed; read the current state with
  /// [getInitializationState].
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

  /// Notifier object informing the client integration of analytics events the SDK logs for the host app,
  /// for example to forward them to the host app's own analytics.
  ///
  /// The SDK sends nothing anywhere itself. Events are only logged when the client has analytics enabled in the SDK's
  /// CMS and the user accepted it, on the legal screen or the "Datenverarbeitung" screen; [resetAnalyticsConsent] asks
  /// again. On Android they also need [IaSdkConfiguration.isAnalyticsEnabled], which is on by default.
  ///
  /// Names are listed in [IaSdkAnalyticsEventNames], parameters in [IaSdkAnalyticsParameterNames]. New events are
  /// added over time, so code that switches over names needs a default case.
  ///
  /// ```dart
  /// IaSdk.instance.loggedAnalyticsEventListener.stream.listen((event) {
  ///   // Forward event.name and event.parameters.
  /// });
  /// ```
  ///
  final loggedAnalyticsEventListener = StreamController<IaSdkLoggedAnalyticsEvent>.broadcast();

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
  /// host's screen and the SDK's screen both open. The Android SDK also opens the screens of `IaProductGrid`
  /// (product details) and of `transferPrescriptions` without asking, including the navigation within them.
  ///
  /// Usage:
  ///
  /// ```dart
  /// IaSdk.instance.onSdkWillNavigateToTarget = (navigationTarget) async {
  ///   if (navigationTarget == IaSdkNavigationTarget.cart) {
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
  /// Note: Pharmacies selected in an `apofinderScreen` embedded with `IaSdkPlatformView` aren't reported. On Android
  /// only pharmacies selected in the screen opened with [launchApofinder] are reported.
  ///
  void Function({
    required String pharmacyId,
    required bool isFromPrerequisites,
  })?
  onApofinderDidChangePharmacy;
}
