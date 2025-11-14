package de.ihreapotheken.appsdk_v2_flutter_plugin

import android.content.Context
import de.ihreapotheken.appsdk_v2_flutter_plugin.sdk.IaClientBindings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class IaSdkFlutter :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    lateinit var bindings: IaClientBindings

    var activityContext: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        bindings = IaClientBindings(
            flutterPluginBinding.applicationContext,
            { activityContext },
            flutterPluginBinding.binaryMessenger,
            flutterPluginBinding.platformViewRegistry,
        )
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        // Do nothing.
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Do nothing.
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityContext = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityContext = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityContext = binding.activity
    }

    override fun onDetachedFromActivity() {
        activityContext = null
    }
}
