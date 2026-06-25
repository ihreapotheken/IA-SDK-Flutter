part of '../../core.dart';

class _RequestModelSetUserAddress implements IaBaseRequest {
  _RequestModelSetUserAddress({
    required this.firstName,
    required this.lastName,
    this.additionalInfo,
    required this.street,
    required this.houseNumber,
    required this.zipCode,
    required this.city,
    this.salutation,
    this.phoneNumberCountryCode,
    this.phoneNumberWithoutCountryCode,
  });

  final String firstName, lastName;

  final String? additionalInfo;

  final String street, houseNumber, zipCode, city;

  final String? salutation;

  final int? phoneNumberCountryCode;

  final String? phoneNumberWithoutCountryCode;

  @override
  Map<String, dynamic> toSupportedType() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'additionalInfo': additionalInfo,
      'street': street,
      'houseNumber': houseNumber,
      'zipCode': zipCode,
      'city': city,
      'salutation': salutation,
      'phoneNumberCountryCode': phoneNumberCountryCode,
      'phoneNumberWithoutCountryCode': phoneNumberWithoutCountryCode,
    };
  }
}
