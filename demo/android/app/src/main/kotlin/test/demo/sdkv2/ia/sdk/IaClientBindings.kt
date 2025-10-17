package test.demo.sdkv2.ia.sdk

import android.content.Context
import de.ihreapotheken.sdk.integrations.api.IaSdk
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry

class IaClientBindings(
    val applicationContext: Context,
    binaryMessenger: BinaryMessenger,
    platformViewRegistry: PlatformViewRegistry,
) {
    private val channel: MethodChannel = MethodChannel(binaryMessenger, "de.ihreapotheken/sdk")

    lateinit var sdkModule: IaSdk

    init {
        val methodHandler = IaClientMethods(this)
        channel.setMethodCallHandler(methodHandler::callHandler)
        for (view in IaClientViews.entries) {
            platformViewRegistry.registerViewFactory(
                view.name,
                IaClientFlutterViewFactory(),
            )
        }
    }
}