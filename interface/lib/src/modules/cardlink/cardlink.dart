part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK CardLink service.
///
abstract class IaBaseCardLink extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.cardLink;
  }
}
