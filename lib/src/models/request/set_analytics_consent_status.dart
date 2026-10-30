part of '../../core.dart';

class _RequestModelSetAnalyticsConsentStatus implements IaBaseRequest {
  _RequestModelSetAnalyticsConsentStatus({
    required this.status,
  });

  final IaSdkAnalyticsConsentStatus status;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'status': status.name,
    };
  }
}
