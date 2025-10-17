package test.demo.sdkv2.ia.sdk

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
         * Places a new [android.app.Activity] object into the navigation stack.
         */
        launchRoute,

        /**
         * Forwards a collection of prescription objects with the ia.de checkout services.
         */
        transferPrescriptions,
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
                bindings.sdkModule = IaSdk.register(
                    OtcModule,
                    OrderingModule,
                    PharmacyModule,
                    RxModule,
                )
                bindings.sdkModule.init(
                    context = bindings.applicationContext,
                    apiKey = accessKey,
                    clientID = clientId,
                )
                result.success(null)
            }

            FlutterCall.launchRoute.name -> {
                val viewId = call.arguments
                if (viewId !is String) {
                    result.error(
                        "ARG_ERROR",
                        "View identifier must be provided as a String type argument \"viewId\".",
                        null,
                    )
                    return
                }
                val intent = Intent(
                    bindings.applicationContext,
                    IaClientComponentActivity::class.java,
                )
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                intent.putExtra("viewId", viewId)
                bindings.applicationContext.startActivity(intent)
                result.success(null)
            }

            FlutterCall.transferPrescriptions.name -> {
                val data = call.arguments
                if (data !is Map<*, *>) {
                    result.error(
                        "ARG_ERROR",
                        "Prescription data must be provided as a Map<*, *> type argument.",
                        null,
                    )
                    return
                }
                val prescriptionImages = data["images"]
                if (prescriptionImages != null && (prescriptionImages !is ArrayList<*> ||
                            prescriptionImages.any { it !is ByteArray })
                ) {
                    result.error(
                        "ARG_ERROR",
                        "Prescription image data must be provided as a ArrayList<ByteData> type argument \"images\".",
                        null,
                    )
                }
                val prescriptionPdfs = data["pdfs"]
                if (prescriptionPdfs != null && (prescriptionPdfs !is ArrayList<*> ||
                            prescriptionPdfs.any { it !is ByteArray })
                ) {
                    result.error(
                        "ARG_ERROR",
                        "Prescription PDF data must be provided as a ArrayList<ByteData> type argument \"pdfs\".",
                        null,
                    )
                }
                val prescriptionCodes = data["codes"]
                if (prescriptionCodes != null && (prescriptionCodes !is ArrayList<*> ||
                            prescriptionCodes.any { it !is ArrayList<*> } ||
                            prescriptionCodes.all { (it as ArrayList<*>).all { it !is String } })
                ) {
                    result.error(
                        "ARG_ERROR",
                        "Prescription code data must be provided as a ArrayList<ArrayList<String>> type argument \"pdfs\".",
                        null,
                    )
                }
                @Suppress("UNCHECKED_CAST")
                bindings.sdkModule.transferPrescriptions(
                    images = prescriptionImages as ArrayList<ByteArray>,
                    pdfs = prescriptionPdfs as ArrayList<ByteArray>,
                    codes = prescriptionCodes as ArrayList<ArrayList<String>>
                )
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }
}