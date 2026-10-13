part of '_models.dart';

/// Details of the selected pharmacy, returned by `getPharmacy`.
///
class IaModelPharmacy {
  /// Constructs a new instance of the [IaModelPharmacy] object.
  ///
  const IaModelPharmacy({
    required this.id,
    required this.name,
    required this.additionalName,
    required this.logoUrl,
    required this.websiteUrl,
    required this.phone,
    required this.email,
    required this.street,
    required this.postcode,
    required this.city,
    required this.isOpenNow,
    required this.isTestPharmacy,
    required this.data,
  });

  /// Creates an instance from the map sent by the native platform.
  ///
  factory IaModelPharmacy.fromMap(Map<String, dynamic> map) {
    final additionalInformation = Map<String, dynamic>.from(map['additionalInformation'] as Map);
    final contact = Map<String, dynamic>.from(map['contact'] as Map);
    final location = Map<String, dynamic>.from(map['location'] as Map);
    final businessHours = Map<String, dynamic>.from(map['businessHours'] as Map);
    return IaModelPharmacy(
      id: '${map['id']}',
      name: additionalInformation['name'] as String,
      additionalName: map['pharmacyAdditionalName'] as String?,
      logoUrl: additionalInformation['logo'] as String,
      websiteUrl: contact['websiteUrl'] as String,
      phone: contact['phone'] as String,
      email: contact['email'] as String,
      street: location['street'] as String,
      postcode: location['postcode'] as String,
      city: location['city'] as String,
      isOpenNow: businessHours['isOpenNow'] as bool,
      isTestPharmacy: additionalInformation['isTestPharmacy'] as bool,
      data: map,
    );
  }

  /// Pharmacy identifier, as used with `setPharmacyId`.
  ///
  final String id;

  /// Pharmacy name.
  ///
  final String name;

  /// Additional pharmacy name, if any.
  ///
  final String? additionalName;

  /// URL of the pharmacy logo.
  ///
  final String logoUrl;

  /// URL of the pharmacy website.
  ///
  final String websiteUrl;

  /// Pharmacy phone number.
  ///
  final String phone;

  /// Pharmacy email address.
  ///
  final String email;

  /// Street and house number.
  ///
  final String street;

  /// Postcode.
  ///
  final String postcode;

  /// City.
  ///
  final String city;

  /// Whether the pharmacy is open right now.
  ///
  final bool isOpenNow;

  /// Whether this is a test pharmacy.
  ///
  final bool isTestPharmacy;

  /// All pharmacy details reported by the SDK, for example `businessHours`, `delivery` and `services`.
  ///
  final Map<String, dynamic> data;
}
