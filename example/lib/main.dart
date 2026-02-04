import 'package:appsdk_v2_flutter_plugin_example/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.secrets');
  runApp(const ExampleApp());
}
