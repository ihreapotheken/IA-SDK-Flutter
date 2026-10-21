import 'package:flutter/material.dart';
import 'package:ia_interface/ia_interface.dart';

/// Embeds the SDK start screen in the tab with [IaSdkPlatformView], instead of launching it.
///
class EmbeddedView extends StatelessWidget {
  const EmbeddedView({super.key});

  @override
  Widget build(BuildContext context) {
    return const IaSdkPlatformView(
      viewId: 'startScreen',
      selfSizing: false,
    );
  }
}
