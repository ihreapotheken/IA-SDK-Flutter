import 'package:appsdk_v2_flutter_plugin_example/src/app.dart';
import 'package:appsdk_v2_flutter_plugin_example/src/e2e/e2e_smoke_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Enabled with `--dart-define=iaE2E=true`. When set, the app boots a minimal
/// E2E smoke entry that verifies the SDK initializes; otherwise the demo app.
const _isE2E = bool.fromEnvironment('iaE2E');

Future<void> main() async {
  await dotenv.load(fileName: '.secrets');
  await dotenv.load(fileName: '.env', mergeWith: Map.of(dotenv.env));
  runApp(_isE2E ? const E2eSmokeApp() : const ExampleApp());
}
