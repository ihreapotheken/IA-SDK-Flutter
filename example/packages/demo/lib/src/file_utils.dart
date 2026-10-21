import 'dart:io';

class FileUtils {
  static Future<String> createDemoCoreAppLogFile() async {
    final file = File('${Directory.systemTemp.path}/demo_app.logs');
    await file.writeAsString(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
      'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
      'nisi ut aliquip ex ea commodo consequat.',
    );
    return file.path;
  }
}
