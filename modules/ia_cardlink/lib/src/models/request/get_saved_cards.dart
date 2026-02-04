part of '../../impl.dart';

class _RequestModelGetSavedCards implements IaBaseRequest {
  _RequestModelGetSavedCards({
    required this.userId,
  });

  final String userId;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'userId': userId,
    };
  }
}
