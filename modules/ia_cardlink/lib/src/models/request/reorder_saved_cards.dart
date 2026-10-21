part of '../../impl.dart';

class _RequestModelReorderSavedCards implements IaBaseRequest {
  _RequestModelReorderSavedCards({
    required this.userId,
    required this.orderedCanCodes,
  });

  final String userId;
  final List<String> orderedCanCodes;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'userId': userId,
      'orderedCanCodes': orderedCanCodes,
    };
  }
}
