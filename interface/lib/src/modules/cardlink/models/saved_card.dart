part of '_models.dart';

/// Data model representing a saved CardLink card (CAN code).
///
class IaCardLinkSavedCard {
  /// Constructs a new instance of [IaCardLinkSavedCard].
  ///
  const IaCardLinkSavedCard({
    required this.name,
    this.canCode,
  });

  /// User-defined name for the saved card.
  ///
  final String name;

  /// The CAN code associated with this card.
  ///
  final String? canCode;

  /// Creates an instance from a map of values.
  ///
  factory IaCardLinkSavedCard.fromMap(Map<String, dynamic> map) {
    return IaCardLinkSavedCard(
      name: map['name'] as String,
      canCode: map['canCode'] as String?,
    );
  }

  /// Converts the saved card to a map representation.
  ///
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (canCode != null) 'canCode': canCode,
    };
  }
}
