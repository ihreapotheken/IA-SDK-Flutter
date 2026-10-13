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

  /// Called when the button is tapped. When `null`, the SDK opens its cart screen.
  ///
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IaSdkPlatformView(
      viewId: 'cartButton',
      onTap: onTap,
    );
  }
}
