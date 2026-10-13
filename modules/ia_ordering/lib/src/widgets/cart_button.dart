import 'package:flutter/widgets.dart';
import 'package:ia_interface/ia_interface.dart';

/// Inline native cart button component.
///
/// On iOS the button takes its own size. On Android it fills the width it's given, so give it a width in a `Row`
/// or an app bar, for example with a `SizedBox`.
///
/// On Android the app's activity must be a `ComponentActivity`, such as `FlutterFragmentActivity`; with
/// `FlutterActivity` creating the component fails.
///
class IaCartButton extends StatelessWidget {
  /// Default constructor for [IaCartButton].
  ///
  const IaCartButton({
    super.key,
    this.onTap,
  });

  /// Called when the button is tapped. When `null`, the SDK opens its cart screen, after asking
  /// `IaSdk.onSdkWillNavigateToTarget` on both platforms.
  ///
  /// Switching between `null` and a callback recreates the native button.
  ///
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IaSdkPlatformView(
      // The native button reads whether it has a tap handler once, so switching between none and one recreates it.
      key: ValueKey(onTap != null),
      viewId: 'cartButton',
      onTap: onTap,
    );
  }
}
