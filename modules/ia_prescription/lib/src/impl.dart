import 'package:ia_interface/ia_interface.dart';

part 'methods.dart';
part 'views.dart';

/// Method and property definitions for the ia.de AppSDK Prescription service.
///
class IaModulePrescription extends IaBasePrescription {
  @override
  Future<void> launchRedeemPrescriptionScreen() async {
    return await _Views.redeemPrescription.launch();
  }
}
