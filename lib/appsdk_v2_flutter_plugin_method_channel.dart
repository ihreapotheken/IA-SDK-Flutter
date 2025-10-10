import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'appsdk_v2_flutter_plugin_platform_interface.dart';

/// An implementation of [AppsdkV2FlutterPluginPlatform] that uses method channels.
class MethodChannelAppsdkV2FlutterPlugin extends AppsdkV2FlutterPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('appsdk_v2_flutter_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
