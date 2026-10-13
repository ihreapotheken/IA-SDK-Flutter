part of '../core.dart';

/// Configuration for CardLink flows the SDK starts itself, for example from the "redeem prescription" screen.
///
/// CardLink flows launched with `IaSdk.instance.cardLink.launch` use the values passed there instead.
///
/// Events of CardLink flows the SDK starts itself are reported through the CardLink module's streams on iOS only,
/// except `willExit`, as the SDK closes and reopens these flows itself. Their terms event is reported for the host
/// app to handle; the SDK only closes CardLink for it. The Android SDK doesn't expose these events.
///
class IaSdkConfigurationCardLink {
  /// Generates an instance of CardLink configuration.
  ///
  const IaSdkConfigurationCardLink({
    this.isSaveCardEnabled,
    this.userId,
    this.phoneNumber,
  });

  /// Whether the user can save their health card. `null` keeps the SDK default, which allows it on iOS but not on
  /// Android.
  ///
  final bool? isSaveCardEnabled;

  /// User identifier under which saved cards are stored. `null` keeps the SDK default.
  ///
  /// The SDK's own lists of saved cards show the cards of the SDK's user, so cards saved under another identifier
  /// don't appear there.
  ///
  /// Note: Only used on iOS.
  ///
  final String? userId;

  /// Phone number to pre-fill. `null` keeps the SDK default.
  ///
  /// When the user picks a saved card, the card's own phone number is used instead.
  ///
  /// Note: Only used on iOS.
  ///
  final String? phoneNumber;

  /// Serialises the class data to a JSON-compatible format.
  ///
  Map<String, dynamic> toJson() {
    return {
      'isSaveCardEnabled': isSaveCardEnabled,
      'userId': userId,
      'phoneNumber': phoneNumber,
    };
  }
}
