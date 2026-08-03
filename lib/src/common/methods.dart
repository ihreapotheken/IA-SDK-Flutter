part of '../core.dart';

enum _Methods with IaBaseMethods implements IaBaseMethods {
  register,

  initialize,

  setGuestUserData,

  logout,

  finishAllActivities,

  transferSDKv1UserData,

  isInitialized,

  deleteUser,

  getEnvironment,

  cleanCache,

  setUserBillingAddress,

  setUserDeliveryAddress,

  legacySetupAsCoreApp,

  setShouldShowMascotIllustrations,
  ;

  @override
  String get methodId {
    return name;
  }

  @override
  Type? get argumentType {
    switch (this) {
      case _Methods.register:
        return _RequestModelRegisterModules;
      case _Methods.setGuestUserData:
        return _RequestModelSetGuestUserData;
      case _Methods.cleanCache:
        return _RequestModelCleanCache;
      case _Methods.setUserBillingAddress:
      case _Methods.setUserDeliveryAddress:
        return _RequestModelSetUserAddress;
      case _Methods.setShouldShowMascotIllustrations:
        return _RequestModelSetShouldShowMascotIllustrations;
      default:
        return null;
    }
  }
}
