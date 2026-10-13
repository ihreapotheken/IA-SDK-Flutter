part of '../core.dart';

/// Configuration for CardLink flows the SDK starts itself, for example from the "redeem prescription" screen.
///
/// CardLink flows launched with `IaSdk.instance.cardLink.launch` use the values passed there instead.
///
/// Events of CardLink flows the SDK starts itself are reported through the CardLink module's streams on iOS only,
/// except `willExit`, as the SDK closes and reopens these flows itself. Their cart and terms events are reported for
/// the host app to handle; the SDK only closes CardLink for them. The Android SDK doesn't expose these events.
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
  /// Note: Only used on iOS.
  ///
  final String? userId;

  /// Phone number to pre-fill. `null` keeps the SDK default.
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
