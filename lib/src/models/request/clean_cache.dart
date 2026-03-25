part of '../../core.dart';

class _RequestModelCleanCache implements IaBaseRequest {
  _RequestModelCleanCache({
    required this.initialization,
    required this.prerequisites,
  });

  final bool initialization;
  final bool prerequisites;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'initialization': initialization,
      'prerequisites': prerequisites,
    };
  }
}
