part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK Prescription service.
///
abstract class IaBasePrescription extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.prescription;
  }
}
