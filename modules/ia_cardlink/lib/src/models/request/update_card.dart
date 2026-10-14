part of '../../impl.dart';

class _RequestModelUpdateCard implements IaBaseRequest {
  _RequestModelUpdateCard({
    required this.userId,
    required this.originalName,
    required this.name,
    required this.phoneNumber,
    required this.canCode,
  });

  final String userId;
  final String originalName;
  final String name;
  final String phoneNumber;
  final String canCode;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'userId': userId,
      'originalName': originalName,
      'name': name,
      'phoneNumber': phoneNumber,
      'canCode': canCode,
    };
  }
}
