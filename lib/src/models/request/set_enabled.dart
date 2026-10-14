part of '../../core.dart';

class _RequestModelSetEnabled implements IaBaseRequest {
  _RequestModelSetEnabled({
    required this.enabled,
  });

  final bool enabled;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'enabled': enabled,
    };
  }
}
