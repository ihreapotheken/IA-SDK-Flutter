import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'appsdk_v2_flutter_plugin_method_channel.dart';

abstract class AppsdkV2FlutterPluginPlatform extends PlatformInterface {
  /// Constructs a AppsdkV2FlutterPluginPlatform.
  AppsdkV2FlutterPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppsdkV2FlutterPluginPlatform _instance = MethodChannelAppsdkV2FlutterPlugin();

  /// The default instance of [AppsdkV2FlutterPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppsdkV2FlutterPlugin].
  static AppsdkV2FlutterPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppsdkV2FlutterPluginPlatform] when
  /// they register themselves.
  static set instance(AppsdkV2FlutterPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
