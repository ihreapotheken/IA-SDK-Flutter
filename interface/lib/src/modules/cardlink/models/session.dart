part of '_models.dart';

/// Data model representing a CardLink session.
///
class IaCardLinkSession {
  /// Constructs a new instance of [IaCardLinkSession].
  ///
  const IaCardLinkSession({
    required this.data,
  });

  /// Raw session data returned from the native SDK.
  ///
  final Map<String, dynamic> data;

  /// Creates an instance from a map of values.
  ///
  factory IaCardLinkSession.fromMap(Map<String, dynamic> map) {
    return IaCardLinkSession(data: map);
  }

  /// Converts the session to a map representation.
  ///
  Map<String, dynamic> toMap() {
    return data;
  }
}
