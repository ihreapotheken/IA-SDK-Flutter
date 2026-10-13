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

  resetPrerequisites,

  resetLegalDisclaimer,

  setIsOnboardingShown,

  isPrerequisiteFlowCompleted,

  clearUserBillingAddress,

  clearUserDeliveryAddress,

  setAnalyticsConsent,

  setHapticFeedbackEnabled,

  presentLogs,

  exportLogs,

  getUserId,

  setLogMessageForwardingEnabled,

  removeAllCachedResponses,

  getInitializationState,
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
      case _Methods.setAnalyticsConsent:
        return _RequestModelSetAnalyticsConsent;
      case _Methods.setIsOnboardingShown:
      case _Methods.setHapticFeedbackEnabled:
      case _Methods.setLogMessageForwardingEnabled:
        return _RequestModelSetEnabled;
      default:
        return null;
    }
  }
}
