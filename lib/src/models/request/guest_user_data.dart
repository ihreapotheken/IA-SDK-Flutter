part of '../../core.dart';

class _RequestModelSetGuestUserData implements IaBaseRequest {
  _RequestModelSetGuestUserData({
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumberCountryCode,
    required this.phoneNumberWithoutCountryCode,
  });

  final String salutation;

  final String firstName, lastName;

  final String email;

  final int phoneNumberCountryCode, phoneNumberWithoutCountryCode;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumberCountryCode': phoneNumberCountryCode.toString(),
      'phoneNumberWithoutCountryCode': phoneNumberWithoutCountryCode.toString(),
    };
  }
}
