import 'package:appsdk_v2_flutter_plugin_example/flavor.dart';
import 'package:flutter/material.dart';
import 'package:ia_example_shared/ia_example_shared.dart';

Future<void> main() async {
  await loadExampleEnvironment();
  runApp(ExampleFlavor.current.app);
}
