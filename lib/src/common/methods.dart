part of '../core.dart';

enum _Methods with IaBaseMethods implements IaBaseMethods {
  register,

  initialize,

  setGuestUserData,

  logout,

  finishAllActivities,

  transferSDKv1UserData,
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
      default:
        return null;
    }
  }
}
