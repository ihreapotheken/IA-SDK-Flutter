part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK Over-the-Counter service.
///
/// Members documented as "Only supported on iOS" or "Only supported on Android" throw a
/// [MissingPluginException] on the other platform.
///
abstract class IaBaseOverTheCounter extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.overTheCounter;
  }

  /// Launches the product search screen experience on top of the navigation stack.
  ///
  /// [focusesOnAppear] decides whether the search field is focused when the screen opens, `null` keeps the SDK default.
  /// It's only used on iOS.
  ///
  Future<void> launchProductSearchRoute({
    bool? focusesOnAppear,
  });

  /// Clears the cached products of product grids, so they're loaded again the next time they're shown.
  ///
  /// Note: Only supported on iOS.
  ///
  Future<void> clearProductGridCache();
}
