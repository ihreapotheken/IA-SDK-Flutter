part of 'impl.dart';

enum _Methods with IaBaseMethods implements IaBaseMethods {
  transferPrescriptions,
  clearCart,
  ;

  @override
  String get methodId {
    return name;
  }

  @override
  Type? get argumentType {
    switch (this) {
      case _Methods.transferPrescriptions:
        return _RequestModelTransferPrescriptions;
      default:
        return null;
    }
  }
}
