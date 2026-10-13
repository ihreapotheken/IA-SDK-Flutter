package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import android.app.Activity
import de.ihreapotheken.sdk.core.api.SdkFeatureProvider
import de.ihreapotheken.sdk.integrations.api.view.IaPrerequisiteActivity
import android.util.Log
import java.util.concurrent.atomic.AtomicBoolean
import de.ihreapotheken.sdk.apofinder.ApofinderModule
import de.ihreapotheken.sdk.appointments.AppointmentsModule
import de.ihreapotheken.sdk.core.SdkModule
import de.ihreapotheken.sdk.core.api.PresentationMode
import de.ihreapotheken.sdk.core.api.listener.HandlingDecision
import de.ihreapotheken.sdk.core.api.listener.PharmacyConfigListener
import de.ihreapotheken.sdk.core.api.listener.PharmacyConfigResult
import de.ihreapotheken.sdk.core.api.listener.TransferPrescriptionEvent
import de.ihreapotheken.sdk.core.api.listener.TransferPrescriptionListener
import de.ihreapotheken.sdk.core.data.EnvironmentType
import de.ihreapotheken.sdk.core.data.PrerequisiteFlowConfiguration
import de.ihreapotheken.sdk.core.data.model.analytics.AnalyticsConsent
import de.ihreapotheken.sdk.core.data.model.sdk.SdkEvent
import de.ihreapotheken.sdk.core.data.model.sdk.SdkEventListener
import de.ihreapotheken.sdk.core.domain.model.prescription.ImagePrescription
import de.ihreapotheken.sdk.core.domain.model.prescription.PdfPrescription
import de.ihreapotheken.sdk.core.domain.model.prescription.PrescriptionInsuranceType
import de.ihreapotheken.sdk.integrations.api.IaSdk
import de.ihreapotheken.sdk.integrations.api.IaSdkConfiguration
import de.ihreapotheken.sdk.integrations.api.IaUserAddress
import de.ihreapotheken.sdk.integrations.api.IaUserData
import de.ihreapotheken.sdk.integrations.api.MockBundlePermissionsSettings
import de.ihreapotheken.sdk.integrations.api.MockForceUpdateSettings
import de.ihreapotheken.sdk.integrations.api.MockSdkFeaturesSettings
import de.ihreapotheken.sdk.integrations.api.QaConfiguration
import de.ihreapotheken.sdk.debugviewer.DebugViewerModule
import de.ihreapotheken.sdk.core.ui.theme.HostUiConfig
import de.ihreapotheken.sdk.core.ui.theme.IAUIConfiguration
import de.ihreapotheken.sdk.core.ui.theme.IAHeaderConfiguration
import de.ihreapotheken.sdk.core.ui.theme.IAHeaderStyle
import de.ihreapotheken.sdk.core.ui.theme.IAPrimaryButtonConfiguration
import de.ihreapotheken.sdk.core.ui.theme.IASecondaryButtonConfiguration
import androidx.compose.ui.graphics.Color
import de.ihreapotheken.sdk.integrations.api.TransferPrescriptionRequest
import de.ihreapotheken.sdk.integrations.api.view.IaSdkActivity
import de.ihreapotheken.sdk.integrations.api.view.IaScreen
import de.ihreapotheken.sdk.integrations.api.view.SdkNavigationTarget
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import de.ihreapotheken.sdk.integrations.api.InitState
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

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

        /**
         * Transfers user data from SDK v1 to the current SDK.
         */
        transferSDKv1UserData,

        /**
         * Returns whether the SDK has been successfully initialized.
         */
        isInitialized,

        /**
         * Deletes the user account from the SDK backend.
         */
        deleteUser,

        /**
         * Returns the current server environment.
         */
        getEnvironment,

        /**
         * Clears cached SDK data.
         */
        cleanCache,

        /**
         * Returns the currently selected pharmacy identifier.
         */
        getPharmacyId,

        /**
         * Returns the current cart details.
         */
        getCartDetails,

        /**
         * Deletes the order history.
         */
        deleteOrderHistory,

        /**
         * Sets the user's billing address used to pre-fill checkout.
         */
        setUserBillingAddress,

        /**
         * Sets the user's delivery address used to pre-fill checkout.
         */
        setUserDeliveryAddress,

        /**
         * Legacy setup required when the host app is the Core app.
         */
        legacySetupAsCoreApp,

        /**
         * Toggles the Pharmi mascot illustrations on an already-initialized SDK. iOS only.
         *
         * [IAUIConfiguration] is an immutable value passed at initialization, so the Android
         * AppSDK has no equivalent of the iOS
         * `IASDK.configuration.uiConfiguration.shouldShowMascotIllustrations`. Configure the
         * mascot through the `uiConfiguration` init option instead, which is honoured on both
         * platforms.
         */
        setShouldShowMascotIllustrations,

        /**
         * Clears the selected pharmacy identifier.
         */
        clearPharmacyId,

        /**
         * Resets the prerequisites state so the prerequisites flow runs again.
         */
        resetPrerequisites,

        /**
         * Clears the cached products of product grids. iOS only, the Android AppSDK has no
         * product grid cache API.
         */
        clearProductGridCache,

        /**
         * Resets the accepted legal documents. iOS only.
         */
        resetLegalDisclaimer,

        /**
         * Marks the onboarding as shown or not shown. iOS only.
         */
        setIsOnboardingShown,

        /**
         * Returns whether the user completed the prerequisites flow.
         */
        isPrerequisiteFlowCompleted,

        /**
         * Removes the user's billing address.
         */
        clearUserBillingAddress,

        /**
         * Removes the user's delivery address.
         */
        clearUserDeliveryAddress,

        /**
         * Sets the user's consent for the SDK's analytics tracking.
         */
        setAnalyticsConsent,

        /**
         * Turns haptic feedback in SDK screens on or off.
         */
        setHapticFeedbackEnabled,

        /**
         * Presents the SDK's log viewer.
         */
        presentLogs,

        /**
         * Writes the SDK's logs to a file and returns its path.
         */
        exportLogs,

        /**
         * Returns the SDK's identifier for the current user. iOS only.
         */
        getUserId,

        /**
         * Turns forwarding of SDK log messages on or off. iOS only, the Android AppSDK doesn't
         * report its log messages.
         */
        setLogMessageForwardingEnabled,

        /**
         * Removes all cached network responses of the SDK. iOS only.
         */
        removeAllCachedResponses,

        /**
         * Stores a pharmacy identifier without validating it. iOS only.
         */
        savePharmacyId,

        /**
         * Changes the camera state of the prescription scanner. iOS only, the Android AppSDK
         * doesn't expose the scanner screen.
         */
        setPrescriptionScannerCameraState,

        /**
         * Returns the current initialization state.
         */
        getInitializationState,
    }

    companion object {
        /**
         * Request code of the [IaPrerequisiteActivity] launched by launchRoute, whose result
         * is reported to Flutter by the plugin's activity result listener.
         */
        const val REQUEST_CODE_PREREQUISITES = 7301

        private const val LOG_TAG = "IaSdkFlutter"
    }

    /**
     * Scope for the AppSDK's suspending calls; results are delivered on the main thread, as Flutter requires.
     */
    private val scope = MainScope()

    /**
     * Cancels pending suspending calls when the Flutter engine detaches.
     */
    fun dispose() {
        scope.cancel()
    }

    /**
     * Runs a suspending AppSDK call and reports its value, or its failure, to Flutter.
     */
    private fun respondSuspending(
        result: MethodChannel.Result,
        block: suspend () -> Any?,
    ) {
        scope.launch {
            try {
                result.success(block())
            } catch (e: Exception) {
                result.error("METHOD_ERROR", e.message, null)
            }
        }
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
                    if (modules.contains("appointments")) AppointmentsModule else null,
                ).toTypedArray<SdkModule>()
                IaSdk.register(
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
                // Dart sends channelId inside the initialization options, not at the top level.
                val channelId = (initializationOptions?.get("channelId") as? Number)?.toInt()
                val shouldShowIndicator = initializationOptions?.get("shouldShowIndicator") == true
                val prerequisites = initializationOptions?.get("prerequisites") as? Map<*, *>
                val shouldRunLegal = prerequisites?.get("runLegalIfNeeded") == true
                val shouldRunOnboarding = prerequisites?.get("runOnboardingIfNeeded") == true
                // Absent value keeps the SDK default (Apofinder runs).
                val shouldRunApofinder = prerequisites?.get("runApofinderIfNeeded") != false
                val uiConfiguration = parseUIConfiguration(args["uiConfiguration"] as? Map<*, *>)
                val footer = args["footer"] as? Map<*, *>
                val shouldShowDataProcessing = footer?.get("shouldShowDataProcessing") == true
                // Absent values keep the SDK defaults.
                val isPickupLockerAndCourierShippingEnabled = args["isPickupLockerAndCourierShippingEnabled"] as? Boolean ?: false
                val isAnalyticsEnabled = args["isAnalyticsEnabled"] as? Boolean ?: false
                val isHapticFeedbackEnabled = args["isHapticFeedbackEnabled"] as? Boolean ?: true
                val playStoreId = args["playStoreId"] as? String
                val qaConfiguration = args["qaConfiguration"] as? Map<*, *>
                if (qaConfiguration != null) {
                    IaSdk.setQaConfiguration(parseQaConfiguration(qaConfiguration))
                }
                val isCardLinkSaveCardEnabled = (args["cardLink"] as? Map<*, *>)?.get("isSaveCardEnabled") as? Boolean ?: false
                // Footer "Datenverarbeitung" taps are reported like the iOS hostAppPrivacyPolicy navigation target.
                bindings.sdkModule.setShowDataProcessingClickListener(bindings.callbacks)
                // A set imprint listener replaces the SDK's own imprint page, so it's only set when the host handles it.
                if (footer?.get("isImprintHandledByHostApp") == true) {
                    bindings.sdkModule.setImpressumClickListener(bindings.callbacks)
                }
                bindings.sdkModule.setAnalyticsListener(bindings.callbacks)
                val hasReplied = AtomicBoolean(false)
                bindings.sdkModule.init(
                    context = bindings.applicationContext,
                    apiKey = accessKey,
                    clientId = clientId,
                    configuration = IaSdkConfiguration(
                        shouldFetchThemeFromRemote = shouldFetchThemeFromRemote,
                        prerequisiteFlowConfiguration = PrerequisiteFlowConfiguration(
                            shouldRunLegal = shouldRunLegal,
                            shouldRunOnboarding = shouldRunOnboarding,
                        ).apply {
                            setSkipApofinderInPrerequisites(!shouldRunApofinder)
                        },
                        channelId = channelId,
                        shouldShowIndicator = shouldShowIndicator,
                        uiConfiguration = uiConfiguration,
                        isPickupLockerAndCourierShippingEnabled = isPickupLockerAndCourierShippingEnabled,
                        analyticsEnabled = isAnalyticsEnabled,
                        hapticFeedbackEnabled = isHapticFeedbackEnabled,
                        playStoreId = playStoreId,
                        isSaveCardEnabled = isCardLinkSaveCardEnabled,
                    ),
                    environmentType = serverEnv,
                    sdkEventListener = SdkEventListener { event ->
                        // The listener keeps receiving SDK events after initialization, but Flutter
                        // accepts only one reply per call.
                        if (event is SdkEvent.InitStatus.InitializationCompleted) {
                            attachSdkListeners(shouldShowDataProcessing)
                            if (!hasReplied.getAndSet(true)) {
                                result.success(null)
                            }
                        } else if (event is SdkEvent.InitStatus.AlreadyInitialized) {
                            // The SDK sends this whenever it isn't uninitialized: it may still be initializing, have
                            // failed, or outlive a recreated Flutter engine whose new callbacks need attaching.
                            scope.launch {
                                val state = IaSdk.initState.first { it == InitState.INITIALIZED || it == InitState.ERROR }
                                if (state == InitState.INITIALIZED) {
                                    attachSdkListeners(shouldShowDataProcessing)
                                    if (!hasReplied.getAndSet(true)) {
                                        result.success(null)
                                    }
                                } else if (!hasReplied.getAndSet(true)) {
                                    result.error(
                                        "INIT_ERROR",
                                        "An earlier initialization failed, and the SDK can't be initialized again until the app restarts.",
                                        null,
                                    )
                                }
                            }
                        } else if (event is SdkEvent.InitError) {
                            if (!hasReplied.getAndSet(true)) {
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
                val salutation = normalizedSalutation(args["salutation"] as? String ?: "")
                val firstName = args["firstName"] as String
                val lastName = args["lastName"] as String
                val email = args["email"] as String
                val phoneNumberCountryCode = args["phoneNumberCountryCode"] as String?
                val phoneNumberWithoutCountryCode = args["phoneNumberWithoutCountryCode"] as String?
                val userData = IaUserData(
                    salutation = salutation,
                    firstName = firstName,
                    lastName = lastName,
                    email = email,
                    countryCode = if (phoneNumberCountryCode != null) {
                        phoneNumberCountryCode.toIntOrNull() ?: 49
                    } else {
                        null
                    },
                    phoneNumberWithoutCountryCode = phoneNumberWithoutCountryCode,
                )
                bindings.sdkModule.setUserData(
                    userData
                )
                result.success(null)
            }

            FlutterCall.setUserBillingAddress.name,
            FlutterCall.setUserDeliveryAddress.name -> {
                val args = call.arguments
                if (args !is Map<*, *>) {
                    result.error(
                        "ARG_ERROR",
                        "Arguments for ${call.method} must be of Map type.",
                        null,
                    )
                    return
                }
                val address = parseUserAddress(args)
                if (address == null) {
                    result.error(
                        "ARG_ERROR",
                        "Missing or invalid argument types. Expected String values for firstName, lastName, street, houseNumber, zipCode and city.",
                        null,
                    )
                    return
                }
                if (!requireInitialized(result)) return
                if (call.method == FlutterCall.setUserBillingAddress.name) {
                    bindings.sdkModule.setUserBillingAddress(address)
                } else {
                    bindings.sdkModule.setUserDeliveryAddress(address)
                }
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
                    IaScreen.ApofinderScreen::class.simpleName -> IaScreen.ApofinderScreen
                    IaScreen.RedeemPrescription::class.simpleName -> IaScreen.RedeemPrescription
                    // iOS-only screens, reported like the other platform-only calls.
                    "PrescriptionScanner", "EPrescriptionScanner" -> {
                        result.notImplemented()
                        return
                    }
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
                val onNavigateToTarget: suspend (SdkNavigationTarget) -> Boolean = { target ->
                    bindings.callbacks.handleNavigationTarget(target)
                }
                val onBackAction: suspend () -> Boolean = {
                    bindings.callbacks.handleBackAction()
                }
                val activity = activityContext as? Activity
                if (entryPoint == IaScreen.PrerequisiteFlow && activity != null) {
                    // The dedicated prerequisites activity reports whether the flow completed or was cancelled.
                    // Without an activity the flow still opens below, but its result can't be reported.
                    activity.startActivityForResult(
                        IaPrerequisiteActivity.createIntent(activity),
                        REQUEST_CODE_PREREQUISITES,
                    )
                } else if (entryPoint == IaScreen.ApofinderScreen) {
                    // Report the selected pharmacy, like the iOS apofinderDidChangePharmacy delegate call.
                    IaSdkActivity.start(
                        context = activityContext ?: bindings.applicationContext,
                        view = IaScreen.ApofinderScreen,
                        onBackAction = onBackAction,
                        onNavigateToTarget = onNavigateToTarget,
                        onResult = { selection ->
                            bindings.callbacks.onApofinderPharmacySelected(selection.pharmacyId)
                        },
                    )
                } else {
                    IaSdkActivity.start(
                        context = activityContext ?: bindings.applicationContext,
                        view = entryPoint,
                        onBackAction = onBackAction,
                        onNavigateToTarget = onNavigateToTarget,
                    )
                }
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
                        "Prescription image data must be provided as a List<Uint8List> type argument \"images\".",
                        null,
                    )
                    return
                }
                val prescriptionPdfs = data["pdfs"]
                if (prescriptionPdfs != null && prescriptionPdfs !is ArrayList<*>) {
                    result.error(
                        "ARG_ERROR",
                        "Prescription PDF data must be provided as a List<Map> type argument \"pdfs\".",
                        null,
                    )
                    return
                }
                val prescriptionCodes = data["codes"]
                if (prescriptionCodes != null && (prescriptionCodes !is ArrayList<*> ||
                            prescriptionCodes.any { it !is String })
                ) {
                    result.error(
                        "ARG_ERROR",
                        "Prescription code data must be provided as a List<String> type argument \"codes\".",
                        null,
                    )
                    return
                }
                val activity = bindings.activityContext() as? Activity
                if (activity == null) {
                    result.error("NO_ACTIVITY", "Transferring prescriptions needs an activity.", null)
                    return
                }
                val orderId = data["orderId"] as? String
                // Map PDF entries with insurance type
                @Suppress("UNCHECKED_CAST")
                val pdfPrescriptions = (prescriptionPdfs as? ArrayList<Map<String, Any>>)?.map { pdfMap ->
                    val pdfData = pdfMap["data"] as ByteArray
                    val insuranceTypeStr = pdfMap["insuranceType"] as? String
                    val insuranceType = when (insuranceTypeStr) {
                        "privateInsurance" -> PrescriptionInsuranceType.PRIVATE
                        "publicHealthcare" -> PrescriptionInsuranceType.PUBLIC
                        else -> PrescriptionInsuranceType.PUBLIC
                    }
                    PdfPrescription(insuranceType, pdfData)
                }
                val imagePrescriptions = (prescriptionImages as? ArrayList<ByteArray>)?.map {
                    ImagePrescription(it)
                }
                // Note: CheckoutListener is already set globally in init, but we still need to
                // update orderSignatures for prescription-specific flows
                // The global listener will handle the Flutter callback
                if (SdkFeatureProvider.orderingFeatureProvider == null) {
                    // The SDK would only show a "not included in your subscription" message and never report back.
                    result.error("METHOD_ERROR", "Ordering isn't available. Is the ordering module registered and entitled?", null)
                    return
                }
                // The listener can report several events, but Flutter accepts only one reply per call.
                val hasReplied = AtomicBoolean(false)
                val isStarted = bindings.sdkModule.ordering.transferPrescriptions(
                    context = activity,
                    transferPrescriptionRequest = TransferPrescriptionRequest(
                        images = imagePrescriptions,
                        pdfs = pdfPrescriptions,
                        codes = prescriptionCodes as? ArrayList<String>,
                        orderId = orderId,
                    ),
                    // OVERLAY shows a confirmation bottom sheet, every other mode opens the cart.
                    // Android has no counterpart of the iOS noAction finish action.
                    presentationMode = if (data["finishAction"] == "showBottomSheet") {
                        PresentationMode.OVERLAY
                    } else {
                        PresentationMode.FULL_FLOW
                    },
                    transferPrescriptionListener = object : TransferPrescriptionListener {
                        override fun onTransferPrescriptionEvent(event: TransferPrescriptionEvent): HandlingDecision {
                            if (event is TransferPrescriptionEvent.Success && !hasReplied.getAndSet(true)) {
                                result.success(null)
                            }
                            if (event is TransferPrescriptionEvent.Failed && !hasReplied.getAndSet(true)) {
                                result.error(
                                    "METHOD_ERROR",
                                    event.errorMessage,
                                    null,
                                )
                            }
                            return HandlingDecision.PERFORM_DEFAULT
                        }
                    },
                )
                // The SDK returns false without calling the listener, for example before it's initialized.
                if (!isStarted && !hasReplied.getAndSet(true)) {
                    result.error("METHOD_ERROR", "The SDK couldn't start the prescription transfer. Is it initialized?", null)
                }
            }

            FlutterCall.finishAllActivities.name -> {
                // SDK screens ask onSdkBackAction before closing, which finishAllActivities skips.
                bindings.callbacks.skipBackActionWhileFinishingAll()
                IaSdkActivity.finishAllActivities()
                // The prerequisites activity isn't one of the SDK's tracked screens.
                (bindings.activityContext() as? Activity)?.finishActivity(REQUEST_CODE_PREREQUISITES)
                result.success(null)
            }

            FlutterCall.transferSDKv1UserData.name -> {
                IaSdk.transferSDKv1UserData(bindings.applicationContext)
                result.success(null)
            }

            FlutterCall.legacySetupAsCoreApp.name -> {
                result.success(null)
            }

            FlutterCall.isInitialized.name -> {
                result.success(bindings.sdkModule.isInitialized())
            }

            FlutterCall.getPharmacyId.name -> {
                scope.launch {
                    val pharmacyId = try {
                        bindings.sdkModule.pharmacy.getPharmacyId().ifEmpty { null }
                    } catch (e: Exception) {
                        // Reported as "no pharmacy selected", as before, but no longer silently.
                        Log.w(LOG_TAG, "Reading the pharmacy ID failed.", e)
                        null
                    }
                    result.success(pharmacyId)
                }
            }

            FlutterCall.clearPharmacyId.name -> {
                if (!requireInitialized(result)) return
                respondSuspending(result) {
                    bindings.sdkModule.pharmacy.clearPharmacyId()
                    null
                }
            }

            FlutterCall.resetPrerequisites.name -> {
                val success = bindings.sdkModule.resetPrerequisites()
                if (success) {
                    result.success(null)
                } else {
                    result.error(
                        "METHOD_ERROR",
                        "Failed to reset prerequisites.",
                        null
                    )
                }
            }

            FlutterCall.isPrerequisiteFlowCompleted.name -> {
                respondSuspending(result) {
                    bindings.sdkModule.isPrerequisiteFlowCompleted()
                }
            }

            FlutterCall.clearUserBillingAddress.name -> {
                if (!requireInitialized(result)) return
                bindings.sdkModule.setUserBillingAddress(null)
                result.success(null)
            }

            FlutterCall.clearUserDeliveryAddress.name -> {
                if (!requireInitialized(result)) return
                bindings.sdkModule.setUserDeliveryAddress(null)
                result.success(null)
            }

            FlutterCall.setAnalyticsConsent.name -> {
                val consent = when ((call.arguments as? Map<*, *>)?.get("consent")) {
                    "granted" -> AnalyticsConsent.GRANTED
                    "denied" -> AnalyticsConsent.DENIED
                    "unknown" -> AnalyticsConsent.UNKNOWN
                    else -> {
                        result.error(
                            "ARG_ERROR",
                            "Missing or invalid consent. Expected one of granted, denied or unknown.",
                            null,
                        )
                        return
                    }
                }
                if (!requireInitialized(result)) return
                bindings.sdkModule.setAnalyticsConsent(consent)
                result.success(null)
            }

            FlutterCall.setHapticFeedbackEnabled.name -> {
                val enabled = (call.arguments as? Map<*, *>)?.get("enabled") as? Boolean
                if (enabled == null) {
                    result.error(
                        "ARG_ERROR",
                        "Missing or invalid enabled. Expected Boolean value for enabled.",
                        null,
                    )
                    return
                }
                bindings.sdkModule.setHapticFeedbackEnabled(enabled)
                result.success(null)
            }

            FlutterCall.getInitializationState.name -> {
                result.success(IaClientCallbacks.initStateName(IaSdk.initState.value))
            }

            FlutterCall.getEnvironment.name -> {
                result.success(
                    when (EnvironmentType.current()) {
                        EnvironmentType.DEV -> "development"
                        EnvironmentType.STAGING -> "staging"
                        EnvironmentType.PROD -> "production"
                    }
                )
            }

            FlutterCall.presentLogs.name -> {
                val provider = SdkFeatureProvider.debugViewerFeatureProvider
                if (provider == null) {
                    result.error("METHOD_ERROR", "The SDK log viewer isn't available.", null)
                    return
                }
                provider.openDebugViewer(bindings.activityContext() ?: bindings.applicationContext)
                result.success(null)
            }

            FlutterCall.exportLogs.name -> {
                respondSuspending(result) {
                    withContext(Dispatchers.IO) {
                        DebugViewerModule.exportLogs(bindings.applicationContext)?.absolutePath
                    }
                }
            }

            FlutterCall.deleteUser.name,
            FlutterCall.cleanCache.name,
            FlutterCall.getCartDetails.name,
            FlutterCall.deleteOrderHistory.name,
            FlutterCall.setShouldShowMascotIllustrations.name,
            FlutterCall.clearProductGridCache.name,
            FlutterCall.resetLegalDisclaimer.name,
            FlutterCall.setIsOnboardingShown.name,
            FlutterCall.getUserId.name,
            FlutterCall.savePharmacyId.name,
            FlutterCall.setPrescriptionScannerCameraState.name,
            FlutterCall.setLogMessageForwardingEnabled.name,
            FlutterCall.removeAllCachedResponses.name -> {
                result.notImplemented()
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Maps the case-insensitive salutation values to the labels the AppSDK lists in its
     * salutation picker ("Frau", "Herr", "Divers", "Keine Angabe"). Unknown values are stored as
     * "Keine Angabe", as on iOS.
     */
    private fun normalizedSalutation(salutation: String): String {
        return when (salutation.trim().lowercase()) {
            "herr" -> "Herr"
            "frau" -> "Frau"
            "divers", "diverse" -> "Divers"
            else -> "Keine Angabe"
        }
    }

    private fun parseQaConfiguration(map: Map<*, *>): QaConfiguration {
        val mockSdkFeatures = map["mockSdkFeatures"] as? Map<*, *>
        val mockBundlePermissions = map["mockBundlePermissions"] as? Map<*, *>
        val mockForceUpdate = map["mockForceUpdate"] as? Map<*, *>
        return QaConfiguration(
            mockSdkFeaturesSettings = mockSdkFeatures?.let {
                MockSdkFeaturesSettings(
                    mockEnabled = true,
                    isExpressDeliveryEnabled = it["isExpressDeliveryEnabled"] != false,
                    isOnlinePaymentEnabled = it["isOnlinePaymentEnabled"] != false,
                    isTrackingEnabled = it["isTrackingEnabled"] == true,
                    isCardLinkEnabled = it["isCardLinkEnabled"] != false,
                )
            },
            mockBundlePermissionsSettings = mockBundlePermissions?.let {
                MockBundlePermissionsSettings(
                    mockEnabled = true,
                    enableOtc = it["isOverTheCounterEnabled"] != false,
                    enableOrdering = it["isOrderingEnabled"] != false,
                    enablePharmacy = it["isPharmacyEnabled"] != false,
                    enableRx = it["isPrescriptionEnabled"] != false,
                    enableCardlink = it["isCardLinkEnabled"] != false,
                )
            },
            mockForceUpdateSettings = mockForceUpdate?.let {
                val defaults = MockForceUpdateSettings()
                MockForceUpdateSettings(
                    mockEnabled = true,
                    type = if (it["isHardUpdate"] == true) "HARD" else "SOFT",
                    minimumVersion = it["minimumVersion"] as? String ?: defaults.minimumVersion,
                    message = it["message"] as? String ?: defaults.message,
                    playStoreId = it["playStoreId"] as? String,
                )
            },
            showTestPharmaciesInApofinder = map["showTestPharmaciesInApofinder"] == true,
            maxScrollSpeed = (map["maxScrollSpeed"] as? Number)?.toFloat(),
            apofinderCustomPharmacyId = (map["apofinderCustomPharmacyId"] as? Number)?.toInt(),
        )
    }

    private fun parseUserAddress(map: Map<*, *>): IaUserAddress? {
        val firstName = map["firstName"] as? String ?: return null
        val lastName = map["lastName"] as? String ?: return null
        val street = map["street"] as? String ?: return null
        val houseNumber = map["houseNumber"] as? String ?: return null
        val zipCode = map["zipCode"] as? String ?: return null
        val city = map["city"] as? String ?: return null
        val countryCode = (map["phoneNumberCountryCode"] as? Number)?.toInt()
        // Like iOS, the phone number is only set when both of its parts are present.
        val phoneNumber = (map["phoneNumberWithoutCountryCode"] as? String)?.takeIf { countryCode != null }
        return IaUserAddress(
            // The AppSDK maps missing address values to empty strings, so an empty
            // salutation leaves it unset, matching a `nil` salutation on iOS.
            salutation = (map["salutation"] as? String)?.let(::normalizedSalutation) ?: "",
            firstName = firstName,
            lastName = lastName,
            street = street,
            houseNumber = houseNumber,
            zipCode = zipCode,
            city = city,
            phoneNumber = phoneNumber,
            countryCode = if (phoneNumber != null) countryCode else null,
            // The AppSDK labels this field "Firma, c/o, Gebäude oder Zusatzinformation",
            // the counterpart of the iOS `additionalInfo` address line.
            company = map["additionalInfo"] as? String,
        )
    }

    /**
     * Attaches the plugin's listeners to the initialized SDK, and applies the settings that need an
     * initialized SDK.
     */
    private fun attachSdkListeners(shouldShowDataProcessing: Boolean) {
        bindings.sdkModule.ordering.setCartListener(bindings.callbacks)
        bindings.sdkModule.ordering.setCheckoutListener(bindings.callbacks)
        bindings.sdkModule.rx.setRedeemPrescriptionListener(bindings.callbacks)
        bindings.sdkModule.setHostUiConfig(HostUiConfig(showDataProcessing = shouldShowDataProcessing))
    }

    /**
     * Replies an error and returns `false` when the SDK isn't initialized. The SDK silently ignores
     * these calls before its initialization, so they'd otherwise report success without effect.
     */
    private fun requireInitialized(result: MethodChannel.Result): Boolean {
        if (bindings.sdkModule.isInitialized()) return true
        result.error("SDK_NOT_INITIALIZED", "Call initialize first; the SDK ignores this call before it's initialized.", null)
        return false
    }

    /**
     * Dart sends colors as ARGB ints. `Color(Long)` is Compose's ARGB factory, unlike the
     * `Color(ULong)` constructor, which expects Compose's packed color value.
     */
    private fun argbColor(argb: Long): Color = Color(argb)

    private fun parseUIConfiguration(map: Map<*, *>?): IAUIConfiguration {
        if (map == null) return IAUIConfiguration()

        val headerMap = map["header"] as? Map<*, *>
        val primaryMap = map["primaryButton"] as? Map<*, *>
        val secondaryMap = map["secondaryButton"] as? Map<*, *>

        // Absent or non-Boolean value keeps the SDK default (mascot shown), so older
        // Dart callers that predate this key behave exactly as before.
        val shouldShowMascotIllustrations = map["shouldShowMascotIllustrations"] as? Boolean

        return IAUIConfiguration(
            header = parseHeaderConfiguration(headerMap),
            primaryButton = parsePrimaryButtonConfiguration(primaryMap),
            secondaryButton = parseSecondaryButtonConfiguration(secondaryMap),
            shouldShowMascotIllustrations = shouldShowMascotIllustrations ?: true,
        )
    }

    private fun parseHeaderConfiguration(map: Map<*, *>?): IAHeaderConfiguration {
        if (map == null) return IAHeaderConfiguration()
        return IAHeaderConfiguration(
            style = if (map["style"] == "monotone") IAHeaderStyle.MONOTONE else IAHeaderStyle.DUOTONE,
            primaryColor = (map["primaryColor"] as? Number)?.toLong()?.let(::argbColor),
            secondaryColor = (map["secondaryColor"] as? Number)?.toLong()?.let(::argbColor),
        )
    }

    private fun parsePrimaryButtonConfiguration(map: Map<*, *>?): IAPrimaryButtonConfiguration {
        if (map == null) return IAPrimaryButtonConfiguration()
        return IAPrimaryButtonConfiguration(
            backgroundColor = (map["backgroundColor"] as? Number)?.toLong()?.let(::argbColor),
            backgroundDisabledColor = (map["backgroundDisabledColor"] as? Number)?.toLong()?.let(::argbColor),
            textColor = (map["textColor"] as? Number)?.toLong()?.let(::argbColor),
            textDisabledColor = (map["textDisabledColor"] as? Number)?.toLong()?.let(::argbColor),
            borderColor = (map["borderColor"] as? Number)?.toLong()?.let(::argbColor),
            borderDisabledColor = (map["borderDisabledColor"] as? Number)?.toLong()?.let(::argbColor),
            borderWidth = (map["borderWidth"] as? Number)?.toFloat(),
            borderRadius = (map["borderRadius"] as? Number)?.toFloat(),
        )
    }

    private fun parseSecondaryButtonConfiguration(map: Map<*, *>?): IASecondaryButtonConfiguration {
        if (map == null) return IASecondaryButtonConfiguration()
        return IASecondaryButtonConfiguration(
            backgroundColor = (map["backgroundColor"] as? Number)?.toLong()?.let(::argbColor),
            backgroundDisabledColor = (map["backgroundDisabledColor"] as? Number)?.toLong()?.let(::argbColor),
            textColor = (map["textColor"] as? Number)?.toLong()?.let(::argbColor),
            textDisabledColor = (map["textDisabledColor"] as? Number)?.toLong()?.let(::argbColor),
            borderColor = (map["borderColor"] as? Number)?.toLong()?.let(::argbColor),
            borderDisabledColor = (map["borderDisabledColor"] as? Number)?.toLong()?.let(::argbColor),
            borderWidth = (map["borderWidth"] as? Number)?.toFloat(),
            borderRadius = (map["borderRadius"] as? Number)?.toFloat(),
        )
    }
}
