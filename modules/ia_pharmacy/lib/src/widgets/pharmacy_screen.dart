import 'package:ia_interface/ia_interface.dart';

/// The pharmacy details screen, embedded in the host's UI. See [IaSdkScreenView].
///
class IaPharmacyScreen extends IaSdkScreenView {
  /// Default constructor for [IaPharmacyScreen].
  ///
  const IaPharmacyScreen({
    super.key,
    super.embedStyle,
    super.onDismiss,
  });

  @override
  String get viewId {
    return 'pharmacyScreen';
  }
}
