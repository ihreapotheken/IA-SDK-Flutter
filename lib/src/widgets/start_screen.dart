import 'package:ia_interface/ia_interface.dart';

/// The start screen, embedded in the host's UI. See [IaSdkScreenView].
///
/// {@category Presentation}
/// {@category StartScreen}
class IaStartScreen extends IaSdkScreenView {
  /// Default constructor for [IaStartScreen].
  ///
  const IaStartScreen({
    super.key,
    super.embedStyle,
    super.onDismiss,
  });

  @override
  String get viewId {
    return 'startScreen';
  }
}
