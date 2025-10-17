package test.demo.sdkv2.ia

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import test.demo.sdkv2.ia.sdk.IaClientBindings

class MainActivity : FlutterFragmentActivity() {
    lateinit var bindings: IaClientBindings

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        bindings = IaClientBindings(
            application.applicationContext,
            flutterEngine.dartExecutor.binaryMessenger,
            flutterEngine.platformViewsController.registry,
        )
    }
}