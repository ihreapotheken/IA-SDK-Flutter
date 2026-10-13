import 'package:flutter/widgets.dart';
import 'package:ia_interface/ia_interface.dart';

/// Inline native cart button component.
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
