part of '../../impl.dart';

class _RequestModelDeleteCard implements IaBaseRequest {
  _RequestModelDeleteCard({
    required this.userId,
    required this.cardName,
  });

  final String userId;
  final String cardName;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'userId': userId,
      'cardName': cardName,
    };
  }
}
