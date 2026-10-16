import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Access key for the ia.de backend services, shared by every flavor.
///
/// Passed on the command line, or read from the `APPSDK_ACCESS_KEY` entry of the `.secrets` file:
///
/// ```dart
/// flutter run --dart-define iaAccessKey=myKey
/// ```
///
String get iaAccessKey {
  const accessKey = String.fromEnvironment('iaAccessKey');
  if (accessKey.isNotEmpty) {
    return accessKey;
  }
  final envKey = dotenv.env['APPSDK_ACCESS_KEY'];
  if (envKey?.isNotEmpty != true) {
    throw Exception('Missing .secrets file with APPSDK_ACCESS_KEY entry.');
  }
  return envKey!;
}
