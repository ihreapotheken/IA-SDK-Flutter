package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import android.app.Activity
import android.content.Intent
import androidx.lifecycle.MutableLiveData
import de.ihreapotheken.sdk.apofinder.ApofinderModule
import de.ihreapotheken.sdk.core.api.PresentationMode
import de.ihreapotheken.sdk.core.api.listener.CartListener
import de.ihreapotheken.sdk.core.api.listener.CheckoutListener
import de.ihreapotheken.sdk.core.api.listener.HandlingDecision
import de.ihreapotheken.sdk.core.api.listener.PharmacyConfigListener
import de.ihreapotheken.sdk.core.api.listener.PharmacyConfigResult
import de.ihreapotheken.sdk.core.api.listener.TransferPrescriptionEvent
import de.ihreapotheken.sdk.core.api.listener.TransferPrescriptionListener
import de.ihreapotheken.sdk.core.data.EnvironmentType
import de.ihreapotheken.sdk.core.data.PrerequisiteFlowConfiguration
import de.ihreapotheken.sdk.core.data.model.sdk.SdkEvent
import de.ihreapotheken.sdk.core.data.model.sdk.SdkEventListener
import de.ihreapotheken.sdk.core.domain.model.GuestUser
import de.ihreapotheken.sdk.integrations.api.IaSdk
import de.ihreapotheken.sdk.integrations.api.IaSdkConfiguration
import de.ihreapotheken.sdk.integrations.api.TransferPrescriptionRequest
import de.ihreapotheken.sdk.integrations.api.view.IaSdkActivity
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
         * Selects a pharmacy by providing an identifier.
         */
        setPharmacyId,

        /**
         * Resets the state of user cart, clearing any added products or prescriptions.
         */
        clearCart,

        /**
         * Forwards the client personal information to the ia.de library for checkout purposes.
         */
        setGuestUserData,

        /**
         * Resets the user data and onboarding status (pharmacy selection, user consents statuses).
         */
        logout,

        /**
         * Places a new [android.app.Activity] object into the navigation stack.
         */
        launchRoute,

        /**
         * Forwards a collection of prescription objects with the ia.de checkout services.
         */
        transferPrescriptions,

        /**
         * Closes any overlaying ia.de screen contents.
         */
        finishAllActivities,
    }

    /**
     * Listener for the total number of cart items.
     */
    private val cartItemCountListener: MutableLiveData<Int> = MutableLiveData(0)

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
                        "Arguments for initIaSdk must be of Map type.",
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
                val serverEnv = when (serverEnvString) {
                    "development" -> {
                        EnvironmentType.DEV
                    }
                    "staging" -> {
                        EnvironmentType.STAGING
                    }
                    "production" -> {
                        EnvironmentType.PROD
                    }
                    else -> {
                        EnvironmentType.STAGING
                    }
                }
                bindings.sdkModule = IaSdk.register(
                    OtcModule,
                    OrderingModule,
                    PharmacyModule,
                    RxModule,
                    ApofinderModule,
                )
                // TODO: Parse configuration options from args (similar to iOS implementation)
                // The following configuration options should be extracted from args:
                // - shouldFetchThemeFromRemote (args["shouldFetchThemeFromRemote"])
                // - footer configuration (args["footer"])
                // - initialization configuration (args["initialization"])
                // - prerequisites configuration (args["initialization"]["prerequisites"])
                // See iOS implementation in IaClientMethods.swift for reference
                bindings.sdkModule.init(
                    context = bindings.applicationContext,
                    apiKey = accessKey,
                    clientId = clientId,
                    configuration = IaSdkConfiguration(
                        shouldFetchThemeFromRemote = true,
                        prerequisiteFlowConfiguration = PrerequisiteFlowConfiguration(
                            shouldRunLegal = true,
                            shouldRunOnboarding = false,
                        ),
                    ),
                    environmentType = serverEnv,
                    sdkEventListener = object : SdkEventListener {
                        override fun onSdkEvent(event: SdkEvent) {
                            if (event is SdkEvent.InitStatus && event !is SdkEvent.InitStatus.Initializing) {
                                if (event is SdkEvent.InitStatus.InitializationCompleted) {
                                    bindings.sdkModule.ordering.setCartListener(
                                        object : CartListener {
                                            override fun onCartChanged(
                                                totalProducts: Int,
                                                totalPrescription: Int,
                                                totalItems: Int
                                            ) {
                                                cartItemCountListener.value = totalItems
                                            }
                                        }
                                    )
                                }
                                result.success(null)
                            } else if (event is SdkEvent.InitError) {
                                result.error(
                                    "INIT_ERROR",
                                    event.message,
                                    null,
                                )
                            }
                        }
                    }
                )
            }

            FlutterCall.setPharmacyId.name -> {
                val args = call.arguments
                if (args !is Map<*, *>) {
                    result.error(
                        "ARG_ERROR",
                        "Arguments for setPharmacyId must be of Map type.",
                        null,
                    )
                    return
                }
                val pharmacyId = args["pharmacyId"] as? String
                if (pharmacyId == null) {
                    result.error(
                        "ARG_ERROR",
                        "Missing or invalid pharmacyId. Expected String value for pharmacyId.",
                        null,
                    )
                    return
                }

                bindings.sdkModule.pharmacy.setPharmacyId(
                    pharmacyId,
                    object : PharmacyConfigListener {
                        override fun onPharmacyConfigResult(pharmacyConfigResult: PharmacyConfigResult) {
                            if (pharmacyConfigResult is PharmacyConfigResult.NotInitialized
                                || pharmacyConfigResult is PharmacyConfigResult.ValidationFailed) {
                                result.error(
                                    "METHOD_ERROR",
                                    "Setting pharmacy ID failed: $pharmacyConfigResult",
                                    null
                                )
                            } else {
                                result.success(null)
                            }
                        }
                    }
                )
            }

            FlutterCall.clearCart.name -> {
                val success = bindings.sdkModule.ordering.deleteCart()
                if (success) {
                    result.success(null)
                } else {
                    result.error(
                        "METHOD_ERROR",
                        "Failed to clear cart data.",
                        null
                    )
                }
            }

            FlutterCall.setGuestUserData.name -> {
                val args = call.arguments
                if (args !is Map<*, *>) {
                    result.error(
                        "ARG_ERROR",
                        "Arguments for setGuestUserData must be of Map type.",
                        null,
                    )
                    return
                }
                val salutation = args["salutation"] as String
                val firstName = args["firstName"] as String
                val lastName = args["lastName"] as String
                val email = args["email"] as String
                val phoneNumberCountryCode = args["phoneNumberCountryCode"] as String?
                val phoneNumberWithoutCountryCode = args["phoneNumberWithoutCountryCode"] as String?
                val guestUserData = GuestUser(
                    salutation,
                    firstName,
                    lastName,
                    email,
                    if (phoneNumberCountryCode != null) {
                        phoneNumberCountryCode.toIntOrNull() ?: 49
                    } else {
                        null
                    },
                    phoneNumberWithoutCountryCode,
                )
                bindings.sdkModule.setUserData(
                    guestUserData
                )
                result.success(null)
            }

            FlutterCall.logout.name -> {
                val success = bindings.sdkModule.clearAllData()
                if (success) {
                    result.success(null)
                } else {
                    result.error(
                        "METHOD_ERROR",
                        "Failed to logout.",
                        null
                    )
                }
            }

            FlutterCall.launchRoute.name -> {
                val args = call.arguments
                if (args !is Map<*, *>) {
                    result.error(
                        "ARG_ERROR",
                        "Arguments for launchRoute must be of Map type.",
                        null,
                    )
                    return
                }
                val viewId = args["viewId"] as? String
                if (viewId == null) {
                    result.error(
                        "ARG_ERROR",
                        "Missing or invalid viewId. Expected String value for viewId.",
                        null,
                    )
                    return
                }
                val activityContext = bindings.activityContext()
                val intent = Intent(
                    activityContext ?: bindings.applicationContext,
                    IaSdkActivity::class.java,
                )
                if (activityContext == null) {
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                intent.putExtra("viewId", viewId)
                (activityContext ?: bindings.applicationContext).startActivity(intent)
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
                            prescriptionCodes.all { it !is String })
                ) {
                    result.error(
                        "ARG_ERROR",
                        "Prescription code data must be provided as a ArrayList<ArrayList<String>> type argument \"pdfs\".",
                        null,
                    )
                }
                val orderId = data["orderId"] as? String
                IaSdk.ordering.setCheckoutListener(
                    object : CheckoutListener {
                        override fun onCheckoutCompleted(hostOrderId: String, sdkOrderId: String) {
                            bindings.channel.invokeMethod(
                                "didFinishOrder",
                                mapOf(
                                    "iaOrderCode" to sdkOrderId,
                                    "hostOrderCode" to hostOrderId,
                                ),
                            )
                            bindings.orderSignatures.value = IaClientBindings.SignatureCodes(
                                iaOrderCode = sdkOrderId,
                                hostOrderCode = hostOrderId,
                            )
                        }
                    }
                )
                @Suppress("UNCHECKED_CAST")
                bindings.sdkModule.ordering.transferPrescriptions(
                    context = (bindings.activityContext() ?: bindings.applicationContext) as Activity,
                    transferPrescriptionRequest = TransferPrescriptionRequest(
                        images = prescriptionImages as ArrayList<ByteArray>,
                        pdfs = prescriptionPdfs as ArrayList<ByteArray>,
                        codes = prescriptionCodes as ArrayList<String>,
                        orderId = orderId,
                    ),
                    transferPrescriptionListener = object : TransferPrescriptionListener {
                        override fun onTransferPrescriptionEvent(event: TransferPrescriptionEvent): HandlingDecision {
                            if (event is TransferPrescriptionEvent.Success) {
                                result.success(null)
                            }
                            if (event is TransferPrescriptionEvent.Failed) {
                                result.error(
                                    "METHOD_ERROR",
                                    event.errorMessage,
                                    null,
                                )
                            }
                            return HandlingDecision.PERFORM_DEFAULT
                        }
                    },
                    presentationMode = PresentationMode.FULL_FLOW,
                )
            }

            FlutterCall.finishAllActivities.name -> {
                IaSdkActivity.finishAllActivities()
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }
}