part of '_models.dart';

/// Data model representing a saved CardLink card (CAN code).
///
class IaCardLinkSavedCard {
  /// Constructs a new instance of [IaCardLinkSavedCard].
  ///
  const IaCardLinkSavedCard({
    required this.name,
    this.canCode,
    this.id,
    this.phoneNumber,
  });

  /// User-defined name for the saved card.
  ///
  final String name;

  /// The CAN code associated with this card.
  ///
  final String? canCode;

  /// Identifier of the saved card. Only reported on iOS, Android saved cards have no identifier.
  ///
  final String? id;

  /// Phone number linked to the saved card.
  ///
  final String? phoneNumber;

  /// Creates an instance from a map of values.
  ///
  factory IaCardLinkSavedCard.fromMap(Map<String, dynamic> map) {
    return IaCardLinkSavedCard(
      name: map['name'] as String,
      // Native card JSON calls the CAN code "canNumber".
      canCode: (map['canCode'] ?? map['canNumber']) as String?,
      id: map['id'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
    );
  }

  /// Converts the saved card to a map representation.
  ///
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (canCode != null) 'canCode': canCode,
      if (id != null) 'id': id,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}
