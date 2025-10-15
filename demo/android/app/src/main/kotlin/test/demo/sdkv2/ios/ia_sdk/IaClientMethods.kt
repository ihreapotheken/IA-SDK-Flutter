package test.demo.sdkv2.ios.ia_sdk

import android.content.Intent
import de.ihreapotheken.sdk.integrations.api.IaSdk
import de.ihreapotheken.sdk.ordering.OrderingModule
import de.ihreapotheken.sdk.otc.OtcModule
import de.ihreapotheken.sdk.pharmacy.PharmacyModule
import de.ihreapotheken.sdk.rx.RxModule
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter client service call handler.
 */
internal class IaClientMethods(
    private val bindings: IaClientBindings,
) {
    /**
     * Collection of available method invocation identifiers.
     */
    @Suppress("EnumEntryName")
    enum class FlutterCall {
        /**
         * Allocates the SDK runtime resources.
         */
        initIaSdk,

        /**
         *
         */
        startComposeActivity,
    }

    fun callHandler(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            FlutterCall.initIaSdk.name -> {
                val args = call.arguments
                if (args !is Map<*, *>) {
                    result.error(
                        "ARG_ERROR",
                        "Arguments for initIaSdk must be of Dictionary type.",
                        null,
                    )
                    return
                }
                val accessKey = args["accessKey"] as? String
                val clientId = args["clientId"] as? String
                val serverEnvString = args["serverEnvironment"] as? String
                if (accessKey == null || clientId == null || serverEnvString == null) {
                    result.error(
                        "ARG_ERROR",
                        "Missing or invalid argument types. Expected String values for accessKey, clientId, and serverEnvironment.",
                        null,
                    )
                    return
                }
                val sdkModule = IaSdk.register(
                    OtcModule,
                    OrderingModule,
                    PharmacyModule,
                    RxModule,
                )
                sdkModule.init(
                    context = bindings.applicationContext,
                    apiKey = accessKey,
                    clientID = clientId,
                )
                result.success(null)
            }

            FlutterCall.startComposeActivity.name -> {
                val intent = Intent(bindings.applicationContext, IaClientComponentActivity::class.java)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                bindings.applicationContext.startActivity(intent)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }
}