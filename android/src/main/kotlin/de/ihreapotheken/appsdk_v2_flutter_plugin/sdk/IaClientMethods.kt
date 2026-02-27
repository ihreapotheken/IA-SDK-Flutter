package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import android.app.Activity
import de.ihreapotheken.sdk.apofinder.ApofinderModule
import de.ihreapotheken.sdk.core.SdkModule
import de.ihreapotheken.sdk.core.api.PresentationMode
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
import de.ihreapotheken.sdk.integrations.api.view.IaScreen
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
         * Register modules.
         */
        register,

        /**
         * Allocates the SDK runtime resources.
         */
        initialize,

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

    fun callHandler(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        when (call.method) {
            FlutterCall.register.name -> {
                val args = call.arguments
                if (args !is Map<*, *>) {
                    result.error(
                        "ARG_ERROR",
                        "Arguments for register modules must be of Map type.",
                        null,
                    )
                    return
                }
                val modules = args["modules"] as? ArrayList<*>
                if (modules == null || modules.any { it !is String }) {
                    result.error(
                        "ARG_ERROR",
                        "Missing or invalid argument types. Expected ArrayList<String> value for modules.",
                        null,
                    )
                    return
                }
                val modulesCollection = listOfNotNull(
                    if (modules.contains("apofinder")) ApofinderModule else null,
                ).toTypedArray<SdkModule>()
                bindings.sdkModule = IaSdk.register(
                    *modulesCollection,
                )
                result.success(null)
            }

            FlutterCall.initialize.name -> {
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
                val shouldFetchThemeFromRemote = args["shouldFetchThemeFromRemote"] == true
                val initializationOptions = args["initialization"] as? Map<*, *>
                val channelId = args["channelId"] as? Int
                val shouldShowIndicator = initializationOptions?.get("shouldShowIndicator") == true
                val prerequisites = initializationOptions?.get("prerequisites") as? Map<*, *>
                val shouldRunLegal = prerequisites?.get("runLegalIfNeeded") == true
                val shouldRunOnboarding = prerequisites?.get("runOnboardingIfNeeded") == true
                bindings.sdkModule.init(
                    context = bindings.applicationContext,
                    apiKey = accessKey,
                    clientId = clientId,
                    configuration = IaSdkConfiguration(
                        shouldFetchThemeFromRemote = true,
                        prerequisiteFlowConfiguration = PrerequisiteFlowConfiguration(
                            shouldRunLegal = shouldRunLegal,
                            shouldRunOnboarding = shouldRunOnboarding,
                        ),
                        channelId = channelId,
                        shouldShowIndicator = shouldShowIndicator,
                    ),
                    environmentType = serverEnv,
                    sdkEventListener = SdkEventListener { event ->
                        if (event is SdkEvent.InitStatus && event !is SdkEvent.InitStatus.Initializing) {
                            if (event is SdkEvent.InitStatus.InitializationCompleted) {
                                // Set up centralized callbacks handler
                                bindings.sdkModule.ordering.setCartListener(bindings.callbacks)
                                bindings.sdkModule.ordering.setCheckoutListener(bindings.callbacks)
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
                
                // Convert viewId string to IaScreen
                val entryPoint = when (viewId) {
                    IaScreen.StartScreen::class.simpleName -> IaScreen.StartScreen
                    IaScreen.CartScreen::class.simpleName -> IaScreen.CartScreen
                    IaScreen.TransferPrescriptionsScreen::class.simpleName -> IaScreen.TransferPrescriptionsScreen
                    IaScreen.SearchScreen::class.simpleName -> IaScreen.SearchScreen
                    IaScreen.PharmacyScreen::class.simpleName -> IaScreen.PharmacyScreen
                    IaScreen.PrerequisiteFlow::class.simpleName -> IaScreen.PrerequisiteFlow
                    else -> {
                        result.error(
                            "ARG_ERROR",
                            "Unknown view identifier: $viewId",
                            null,
                        )
                        return
                    }
                }
                
                // Use the helper function with navigation callback
                // NOTE: Assumes SDK supports: onNavigateToTarget: (suspend (SdkNavigationTarget) -> Boolean)?
                // The lambda automatically becomes suspend because it calls a suspend function
                val activityContext = bindings.activityContext()
                IaSdkActivity.start(
                    context = activityContext ?: bindings.applicationContext,
                    view = entryPoint,
                    onNavigateToTarget = { target ->
                        bindings.callbacks.handleNavigationTarget(target)
                    }
                )
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
                // Note: CheckoutListener is already set globally in init, but we still need to
                // update orderSignatures for prescription-specific flows
                // The global listener will handle the Flutter callback
                val imageBytes = (prescriptionImages as? ArrayList<ByteArray>) ?: emptyList()
                val pdfBytes = (prescriptionPdfs as? ArrayList<ByteArray>) ?: emptyList()
                val codes = (prescriptionCodes as? ArrayList<String>) ?: arrayListOf()
                val images = imageBytes.toList()
                val pdfs = pdfBytes.toList()
                bindings.sdkModule.ordering.transferPrescriptions(
                    context = (bindings.activityContext() ?: bindings.applicationContext) as Activity,
                    transferPrescriptionRequest = TransferPrescriptionRequest(
                        images = images,
                        pdfs = pdfs,
                        codes = codes,
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
