package de.ihreapotheken.appsdk_v2_flutter_plugin

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import de.ihreapotheken.appsdk_v2_flutter_plugin.sdk.IaClientBindings

class IaSdkFlutter :
    FlutterPlugin,
    MethodCallHandler {
    lateinit var bindings: IaClientBindings

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        bindings = IaClientBindings(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger,
            flutterPluginBinding.platformViewRegistry,
        )
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
