part of '../../core.dart';

class _RequestModelSetAnalyticsConsent implements IaBaseRequest {
  _RequestModelSetAnalyticsConsent({
    required this.consent,
  });

  final IaSdkAnalyticsConsent consent;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'consent': consent.name,
    };
  }
}
