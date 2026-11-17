import 'package:ia_interface/ia_interface.dart';

/// The product search screen, embedded in the host's UI. See [IaSdkScreenView].
///
class IaProductSearchScreen extends IaSdkScreenView {
  /// Default constructor for [IaProductSearchScreen].
  ///
  const IaProductSearchScreen({
    super.key,
    super.embedStyle,
    super.onDismiss,
    this.focusesOnAppear,
  });

  /// Whether the search field is focused when the screen opens, `null` keeps the SDK default.
  ///
  /// Note: Only supported on iOS.
  ///
  final bool? focusesOnAppear;

  @override
  String get viewId {
    return 'searchScreen';
  }

  @override
  Map<String, dynamic> get creationParams {
    return {
      if (focusesOnAppear != null) 'focusesOnAppear': focusesOnAppear,
    };
  }
}
