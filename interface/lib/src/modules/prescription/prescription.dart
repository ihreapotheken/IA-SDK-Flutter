part of '../../common/_interface.dart';

abstract class IaBasePrescription extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.prescription;
  }
}
