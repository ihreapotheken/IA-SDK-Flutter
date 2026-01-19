part of '../../impl.dart';

class _RequestModelSetPharmacy implements IaBaseRequest {
  _RequestModelSetPharmacy({
    required this.pharmacyId,
  });

  final String pharmacyId;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'pharmacyId': pharmacyId,
    };
  }
}
