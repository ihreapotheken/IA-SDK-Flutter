import 'package:ia_interface/ia_interface.dart';

/// The redeem prescription screen, embedded in the host's UI. See [IaSdkScreenView].
///
/// The prescription scanners can't be embedded; on Android the user opens them from this screen.
///
class IaRedeemPrescriptionScreen extends IaSdkScreenView {
  /// Default constructor for [IaRedeemPrescriptionScreen].
  ///
  const IaRedeemPrescriptionScreen({
    super.key,
    super.embedStyle,
    super.onDismiss,
  });

  @override
  String get viewId {
    return 'redeemPrescription';
  }
}
