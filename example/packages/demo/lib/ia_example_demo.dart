import 'package:flutter/widgets.dart';
import 'package:ia_example_demo/src/app.dart';
import 'package:ia_example_demo/src/e2e/e2e_config.dart';
import 'package:ia_example_demo/src/e2e/e2e_smoke_host.dart';

/// The demo app, with every plugin API and the test tools. With `--dart-define=iaE2E=true` it's a minimal E2E smoke
/// entry that verifies the SDK initializes.
///
class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return E2EConfig.enabled ? const E2eSmokeApp() : const ExampleApp();
  }
}
