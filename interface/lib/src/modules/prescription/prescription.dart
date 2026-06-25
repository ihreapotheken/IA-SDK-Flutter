part of '../../common/_interface.dart';

/// Method and property definitions for the ia.de AppSDK Prescription service.
///
abstract class IaBasePrescription extends IaBase {
  @override
  IaBaseModule get module {
    return IaBaseModule.prescription;
  }

  /// Launches the "redeem prescription" screen on top of the navigation stack.
  ///
  /// The screen lets the user choose how to add a prescription to the cart
  /// (for example by scanning a QR code, photographing a prescription, or via
  /// CardLink), depending on which capabilities are enabled.
  ///
  Future<void> launchRedeemPrescriptionScreen();
}
