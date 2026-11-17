import 'package:appsdk_v2_flutter_plugin/src/core.dart';
import 'package:ia_interface/ia_interface.dart';

/// The Apofinder (pharmacy finder) screen, embedded in the host's UI. See [IaSdkScreenView].
///
/// When the user selects a pharmacy, it's reported through [IaSdk.onApofinderDidChangePharmacy], and
/// [IaSdkScreenView.onDismiss] is called. The SDK doesn't close the screen itself.
///
/// {@category Presentation}
/// {@category ApofinderScreen}
class IaApofinderScreen extends IaSdkScreenView {
  /// Default constructor for [IaApofinderScreen].
  ///
  const IaApofinderScreen({
    super.key,
    super.embedStyle,
    super.onDismiss,
    this.isCancellable = true,
  });

  /// Whether the user can close Apofinder without selecting a pharmacy.
  ///
  /// Note: Only supported on iOS.
  ///
  final bool isCancellable;

  @override
  String get viewId {
    return 'apofinderScreen';
  }

  @override
  Map<String, dynamic> get creationParams {
    return {
      'isCancellable': isCancellable,
    };
  }
}
