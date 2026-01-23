part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK Over-the-Counter service.
///
abstract class IaBaseOverTheCounter extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.overTheCounter;
  }

  /// Launches the product search screen experience on top of the navigation stack.
  ///
  Future<void> launchProductSearchRoute();
}
