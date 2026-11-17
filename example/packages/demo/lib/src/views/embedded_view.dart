import 'package:appsdk_v2_flutter_plugin/sdk.dart';
import 'package:flutter/material.dart';

/// Embeds the SDK start screen in the tab with [IaStartScreen], instead of launching it.
///
class EmbeddedView extends StatelessWidget {
  const EmbeddedView({super.key});

  @override
  Widget build(BuildContext context) {
    return const IaStartScreen();
  }
}
