import 'package:ia_interface/ia_interface.dart';

part 'common/methods.dart';
part 'common/navigation.dart';
part 'common/views.dart';
part 'config/_config.dart';
part 'config/footer.dart';
part 'config/initialization.dart';
part 'config/server_environment.dart';
part 'models/request/guest_user_data.dart';
part 'models/request/init_config.dart';
part 'models/request/register_modules.dart';
part 'models/request/clean_cache.dart';

/// Main entrypoint for the ia.de AppSDK services and features.
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
      return await _Methods.initialize.invoke(arguments).then((value) {
        _initialized = true;
        return value;
      });
    }
  }

  /// Forwards the client personal information to the ia.de library for checkout purposes.
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

  /// Launches the start screen experience on top of the navigation stack.
  ///
  Future<void> launchStartRoute() async {
    return await _Views.startScreen.launch();
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
  /// Note: Only supported on iOS.
  ///
  Future<IaSdkConfigurationServerEnvironment?> getEnvironment() async {
    final result = await _Methods.getEnvironment.invoke<String?>();
    if (result == null) return null;
    return IaSdkConfigurationServerEnvironment.values.where((e) => e.name == result).firstOrNull;
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

  /// Property holding internal state of the native callback handlers.
  ///
  // ignore: unused_field
  final _callbackHandlers = IaBaseCallbacks(
    handlers: [
      const _NavigationHandler(),
      const _ApofinderPharmacyChangedHandler(),
    ],
  );

  /// Called when the SDK is about to navigate to a destination that the host app can override.
  ///
  /// For example, if the SDK would present the cart screen contents, the host app can switch to its own contents by returning `false`.
  ///
  /// Return `true` to let the SDK proceed with its built-in presentation.
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
  void Function({
    required String pharmacyId,
    required bool isFromPrerequisites,
  })?
  onApofinderDidChangePharmacy;
}
