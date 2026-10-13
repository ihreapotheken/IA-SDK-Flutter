part of '../../core.dart';

/// Request for the methods that switch an SDK option on or off.
///
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
