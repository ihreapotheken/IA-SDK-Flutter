part of '../../impl.dart';

class _RequestModelGetPharmacy implements IaBaseRequest {
  _RequestModelGetPharmacy({
    required this.allowCached,
  });

  final bool allowCached;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'allowCached': allowCached,
    };
  }
}
