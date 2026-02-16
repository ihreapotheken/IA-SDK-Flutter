part of '../../impl.dart';

class _RequestModelLaunch implements IaBaseRequest {
  _RequestModelLaunch({
    required this.sdkApiKey,
    required this.flowType,
    required this.pharmacyId,
    required this.consentStatus,
    required this.phoneNumber,
    required this.userId,
    required this.finishAction,
    this.canCode,
    this.cardName,
    this.primaryColor,
    this.buttonsColor,
    this.textLinkColor,
    this.bottomNavigationColor,
    this.environment,
    this.saveCardEnabled,
    this.appId,
  });

  final String sdkApiKey;
  final IaCardLinkFlowType flowType;
  final String pharmacyId;
  final IaCardLinkConsentStatus consentStatus;
  final String phoneNumber;
  final String userId;
  final IaCardLinkFinishAction finishAction;
  final String? canCode;
  final String? cardName;
  final int? primaryColor;
  final int? buttonsColor;
  final int? textLinkColor;
  final int? bottomNavigationColor;
  final IaCardLinkEnvironment? environment;
  final bool? saveCardEnabled;
  final String? appId;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'sdkApiKey': sdkApiKey,
      'flowType': flowType.rawValue,
      'pharmacyId': pharmacyId,
      'consentStatus': consentStatus.rawValue,
      'phoneNumber': phoneNumber,
      'userId': userId,
      'finishAction': finishAction.rawValue,
      'canCode': canCode,
      'cardName': cardName,
      'primaryColor': primaryColor,
      'buttonsColor': buttonsColor,
      'textLinkColor': textLinkColor,
      'bottomNavigationColor': bottomNavigationColor,
      'environment': environment?.rawValue,
      'saveCardEnabled': saveCardEnabled,
      'appId': appId,
    };
  }
}
