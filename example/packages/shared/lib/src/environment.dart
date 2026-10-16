import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Loads the `.secrets` and `.env` assets of the example app: the access key, see [iaAccessKey], and the native SDK
/// versions the demo shows.
///
Future<void> loadExampleEnvironment() async {
  await dotenv.load(fileName: '.secrets');
  await dotenv.load(fileName: '.env', mergeWith: Map.of(dotenv.env));
}
