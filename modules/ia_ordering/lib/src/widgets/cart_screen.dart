import 'package:ia_interface/ia_interface.dart';

/// The cart screen, embedded in the host's UI. See [IaSdkScreenView].
///
class IaCartScreen extends IaSdkScreenView {
  /// Default constructor for [IaCartScreen].
  ///
  const IaCartScreen({
    super.key,
    super.embedStyle,
    super.onDismiss,
  });

  @override
  String get viewId {
    return 'cartScreen';
  }
}
