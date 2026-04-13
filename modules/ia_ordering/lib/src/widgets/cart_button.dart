import 'package:flutter/widgets.dart';
import 'package:ia_interface/ia_interface.dart';

/// Inline native cart button component.
///
class IaCartButton extends StatelessWidget {
  /// Default constructor for [IaCartButton].
  ///
  const IaCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const IaSdkPlatformView(viewId: 'cartButton');
  }
}
