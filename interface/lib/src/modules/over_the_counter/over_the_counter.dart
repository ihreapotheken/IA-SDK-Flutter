part of '../../common/_interface.dart';

abstract class IaBaseOverTheCounter extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.overTheCounter;
  }

  /// Launches the product search screen experience on top of the navigation stack.
  ///
  Future<void> launchProductSearchRoute();
}
