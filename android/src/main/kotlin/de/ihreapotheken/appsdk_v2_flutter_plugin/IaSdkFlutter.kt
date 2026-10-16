package de.ihreapotheken.appsdk_v2_flutter_plugin

import android.app.Activity
import android.content.Context
import de.ihreapotheken.appsdk_v2_flutter_plugin.sdk.IaClientBindings
import de.ihreapotheken.appsdk_v2_flutter_plugin.sdk.IaClientMethods
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class IaSdkFlutter :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    lateinit var bindings: IaClientBindings

    var activityContext: Context? = null

    private var activityBinding: ActivityPluginBinding? = null

    private val activityResultListener = PluginRegistry.ActivityResultListener { requestCode, resultCode, _ ->
        if (requestCode == IaClientMethods.REQUEST_CODE_PREREQUISITES) {
            bindings.onPrerequisiteFlowFinished(isCancelled = resultCode != Activity.RESULT_OK)
            true
        } else {
            false
        }
    }

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
        bindings.dispose()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityContext = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(activityResultListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        detachFromActivity()
        // Unlike after a configuration change, no activity comes back to receive the prerequisites result.
        bindings.onActivityClosed()
    }

    private fun detachFromActivity() {
        activityBinding?.removeActivityResultListener(activityResultListener)
        activityBinding = null
        activityContext = null
    }
}
