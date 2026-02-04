part of '../../impl.dart';

class _RequestModelLaunch implements IaBaseRequest {
  _RequestModelLaunch({
    required this.sdkApiKey,
    required this.flowType,
    required this.pharmacyId,
    required this.consentStatus,
    required this.phoneNumber,
    required this.userId,
    this.canCode,
    this.cardName,
    this.primaryColor,
    this.buttonsColor,
    this.textLinkColor,
    this.bottomNavigationColor,
    this.environment,
  });

  final String sdkApiKey;
  final IaCardLinkFlowType flowType;
  final String pharmacyId;
  final IaCardLinkConsentStatus consentStatus;
  final String phoneNumber;
  final String userId;
  final String? canCode;
  final String? cardName;
  final int? primaryColor;
  final int? buttonsColor;
  final int? textLinkColor;
  final int? bottomNavigationColor;
  final IaCardLinkEnvironment? environment;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'sdkApiKey': sdkApiKey,
      'flowType': flowType.rawValue,
      'pharmacyId': pharmacyId,
      'consentStatus': consentStatus.rawValue,
      'phoneNumber': phoneNumber,
      'userId': userId,
      'canCode': canCode,
      'cardName': cardName,
      'primaryColor': primaryColor,
      'buttonsColor': buttonsColor,
      'textLinkColor': textLinkColor,
      'bottomNavigationColor': bottomNavigationColor,
      'environment': environment?.rawValue,
    };
  }
}
