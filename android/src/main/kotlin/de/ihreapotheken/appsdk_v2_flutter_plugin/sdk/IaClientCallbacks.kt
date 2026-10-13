package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import android.os.Handler
import android.os.Looper
import androidx.lifecycle.MutableLiveData
import de.ihreapotheken.sdk.core.api.listener.AnalyticsListener
import de.ihreapotheken.sdk.core.api.listener.CartListener
import de.ihreapotheken.sdk.core.api.listener.CheckoutListener
import de.ihreapotheken.sdk.core.api.listener.RedeemPrescriptionDecision
import de.ihreapotheken.sdk.core.api.listener.RedeemPrescriptionEvent
import de.ihreapotheken.sdk.core.api.listener.RedeemPrescriptionListener
import de.ihreapotheken.sdk.core.data.model.analytics.AnalyticsEvent
import de.ihreapotheken.sdk.core.data.model.listener.SdkImpressumListener
import de.ihreapotheken.sdk.core.data.model.listener.SdkShowDataProcessingListener
import de.ihreapotheken.sdk.core.domain.analytics.AnalyticsItem
import de.ihreapotheken.sdk.integrations.api.InitState
import de.ihreapotheken.sdk.integrations.api.view.IaScreen
import de.ihreapotheken.sdk.integrations.api.view.SdkNavigationTarget
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

/**
 * Handles SDK callbacks and forwards them to Flutter via MethodChannel.
 * This is the Android equivalent of iOS's IaClientDelegate.
 *
 * NOTE: This implementation uses suspend functions for async navigation callbacks.
 * This requires the Android SDK to support: onNavigateToTarget: (suspend (SdkNavigationTarget) -> Boolean)?
 */
class IaClientCallbacks(
    private val channel: MethodChannel,
    private val orderSignatures: MutableLiveData<IaClientBindings.SignatureCodes?>,
) : CartListener, CheckoutListener, RedeemPrescriptionListener, SdkShowDataProcessingListener, SdkImpressumListener,
    AnalyticsListener {

    /**
     * Called when the SDK wants to navigate to a specific route.
     * The host app can handle the navigation or let the SDK handle it.
     *
     * This uses suspend/coroutines for async operation - NO THREAD BLOCKING!
     * The coroutine suspends while waiting for Flutter's response, but the thread
     * remains free to do other work.
     *
     * Equivalent to iOS: sdkShouldOverrideRoute -> sdkWillNavigateToTarget
     *
     * @param target The navigation target the SDK wants to navigate to
     * @return true if the host app handled the navigation, false to let SDK handle it
     */
    suspend fun handleNavigationTarget(target: SdkNavigationTarget): Boolean {
        // Convert navigation target to string. SdkNavigationTarget is sealed, so targets added
        // in a new SDK version fail to compile here until they're mapped.
        val navigationTargetString: String = when (target) {
            IaScreen.CartScreen -> "cart"
            IaScreen.PharmacyScreen -> "pharmacyDetails"
            IaScreen.ThankYouScreen -> "thankYou"
            IaScreen.ApofinderScreen -> "apofinder"
            IaScreen.StartScreen -> "start"
            IaScreen.SearchScreen -> "search"
            IaScreen.RedeemPrescription -> "redeemPrescription"
            IaScreen.ThankYouScreenCompleted -> "thankYouCompleted"
            // Note: iOS reports imprint and hostAppPrivacyPolicy as navigation targets,
            // the Android SDK reports footer taps through dedicated click listeners instead
            // (onImpressumClick, onShowDataProcessingClick).
        }

        // Cancellable, so the SDK's 500 ms timeout stops the wait; a late answer is then ignored
        // and the SDK navigates itself. Method channel calls must be made on the main thread.
        val handledByHost = withContext(Dispatchers.Main) {
            suspendCancellableCoroutine { continuation ->
            channel.invokeMethod(
                "sdkWillNavigateToTarget",
                mapOf("navigationTarget" to navigationTargetString),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        // Parse the response
                        val decisionString = result as? String
                        val decision = when (decisionString) {
                            "handled" -> true
                            "performDefault" -> false
                            else -> false
                        }

                        // Resume the suspended coroutine with the result
                        continuation.resume(decision)
                    }

                    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                        // On error, let SDK handle
                        continuation.resume(false)
                    }

                    override fun notImplemented() {
                        // Not implemented, let SDK handle
                        continuation.resume(false)
                    }
                }
            )
            }
        }
        return handledByHost
    }

    /**
     * Called when the cart is updated (items added/removed).
     *
     * Equivalent to iOS: orderingDidUpdateCart
     */
    override fun onCartChanged(
        totalProducts: Int,
        totalPrescription: Int,
        totalItems: Int
    ) {
        // Note: The iOS version receives cartState with totalAmountInCart and clientOrderIDs
        // The Android SDK provides totalProducts, totalPrescription, and totalItems
        // Using totalItems as totalAmountInCart for now
        // The Android SDK doesn't report client order IDs, so the list stays empty.
        val arguments = mapOf(
            "totalAmountInCart" to totalItems,
            "clientOrderIDs" to emptyList<String>(),
            "totalProducts" to totalProducts,
            "totalPrescriptions" to totalPrescription,
        )

        channel.invokeMethod(
            "orderingDidUpdateCart",
            arguments
        )
    }

    /**
     * Called when an order is successfully completed.
     *
     * Equivalent to iOS: orderingDidFinishOrders
     */
    override fun onCheckoutCompleted(hostOrderId: String, sdkOrderId: String) {
        // Update order signatures for prescription flows
        orderSignatures.value = IaClientBindings.SignatureCodes(
            iaOrderCode = sdkOrderId,
            hostOrderCode = hostOrderId,
        )

        // Send callback to Flutter. The SDK reports an empty host order ID when the host didn't
        // pass one, which iOS leaves out of the list.
        val arguments = mapOf(
            "orderCode" to sdkOrderId,
            "orderCodes" to listOf(sdkOrderId),
            "clientOrderIDs" to listOf(hostOrderId).filter { it.isNotEmpty() }
        )

        channel.invokeMethod(
            "orderingDidFinishOrder",
            arguments
        )
    }

    /**
     * Asks Flutter whether an SDK screen may close after the system back action. Closes when
     * Flutter doesn't answer.
     */
    suspend fun handleBackAction(): Boolean {
        return withContext(Dispatchers.Main) {
            suspendCoroutine { continuation ->
                channel.invokeMethod(
                    "sdkBackAction",
                    null,
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            continuation.resume(result as? Boolean ?: true)
                        }

                        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                            continuation.resume(true)
                        }

                        override fun notImplemented() {
                            continuation.resume(true)
                        }
                    }
                )
            }
        }
    }

    /**
     * Called when the prerequisites activity launched by the host app finishes.
     *
     * Equivalent to iOS: sdkDidFinishInitialization with a prerequisites result
     */
    fun onPrerequisiteFlowFinished(isCancelled: Boolean) {
        channel.invokeMethod(
            "sdkPrerequisitesFinished",
            mapOf("isCancelled" to isCancelled)
        )
    }

    /**
     * Called when the SDK initialization state changes.
     *
     * Equivalent to iOS: IASDK.initializationStatePublisher
     */
    fun onInitStateChanged(state: InitState) {
        val stateString = when (state) {
            InitState.UNINITIALIZED -> "uninitialized"
            InitState.INITIALIZING -> "initializing"
            InitState.INITIALIZED -> "initialized"
            InitState.ERROR -> "error"
        }
        channel.invokeMethod(
            "sdkInitializationStateChanged",
            mapOf("state" to stateString)
        )
    }

    /**
     * Called when the SDK tracks an analytics event. Android only, the iOS AppSDK doesn't report analytics.
     */
    override fun onAnalyticsEvent(event: AnalyticsEvent) {
        val (type, parameters) = when (event) {
            is AnalyticsEvent.ScreenView -> "screenView" to mapOf(
                "screenName" to event.screenName,
                "featureName" to event.featureName,
                "properties" to event.properties,
            )
            is AnalyticsEvent.ScreenExit -> "screenExit" to mapOf(
                "screenName" to event.screenName,
                "featureName" to event.featureName,
                "durationMs" to event.durationMs,
                "interactionCount" to event.interactionCount,
                "properties" to event.properties,
            )
            is AnalyticsEvent.UserAction -> "userAction" to mapOf(
                "actionName" to event.actionName,
                "screenName" to event.screenName,
                "properties" to event.properties,
            )
            is AnalyticsEvent.Lifecycle -> "lifecycle" to mapOf(
                "state" to event.state,
            )
            is AnalyticsEvent.Ecommerce -> "ecommerce" to mapOf(
                "eventName" to event.eventName.name,
                "items" to event.items.map { it.toMap() },
                "value" to event.value,
                "currency" to event.currency,
                "transactionId" to event.transactionId,
                "coupon" to event.coupon,
                "screenName" to event.screenName,
                "properties" to event.properties,
            )
            is AnalyticsEvent.Engagement -> "engagement" to mapOf(
                "eventName" to event.eventName.name,
                "screenName" to event.screenName,
                "component" to event.component,
                "elementId" to event.elementId,
                "elementLabel" to event.elementLabel,
                "durationMs" to event.durationMs,
                "properties" to event.properties,
            )
            is AnalyticsEvent.Derived -> "derived" to mapOf(
                "eventName" to event.eventName.name,
                "screenName" to event.screenName,
                "properties" to event.properties,
            )
        }
        val arguments = mapOf(
            "type" to type,
            "eventId" to event.eventId,
            "sessionId" to event.sessionId,
            "timestamp" to event.timestamp,
            "parameters" to parameters,
        )
        // Analytics events aren't guaranteed to arrive on the main thread, which method channel calls require.
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod("sdkAnalyticsEvent", arguments)
        }
    }

    private fun AnalyticsItem.toMap(): Map<String, Any?> = mapOf(
        "id" to id,
        "name" to name,
        "category" to category,
        "price" to price,
        "quantity" to quantity,
        "manufacturer" to manufacturer,
    )

    /**
     * Called when the user selects a pharmacy in an Apofinder screen launched by the host app.
     *
     * Equivalent to iOS: apofinderDidChangePharmacy
     */
    fun onApofinderPharmacySelected(pharmacyId: String) {
        // Activity results aren't guaranteed to arrive on the main thread, which method channel calls require.
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod(
                "apofinderDidChangePharmacy",
                mapOf(
                    "pharmacyId" to pharmacyId,
                    "isFromPrerequisites" to false,
                )
            )
        }
    }

    /**
     * Called when the "Impressum" footer button is tapped, only while the host app handles the imprint
     * (footer option isImprintHandledByHostApp). The SDK then doesn't open its own imprint page.
     *
     * Equivalent to iOS: sdkWillNavigateToTarget(.imprint)
     */
    override fun onImpressumClick() {
        channel.invokeMethod(
            "sdkWillNavigateToTarget",
            mapOf("navigationTarget" to "imprint")
        )
    }

    /**
     * Called when the "Datenverarbeitung" footer button is tapped. The SDK has no default action for it,
     * so the host app's answer is not needed.
     *
     * Equivalent to iOS: sdkWillNavigateToTarget(.hostAppPrivacyPolicy)
     */
    override fun onShowDataProcessingClick() {
        channel.invokeMethod(
            "sdkWillNavigateToTarget",
            mapOf("navigationTarget" to "hostAppPrivacyPolicy")
        )
    }

    /**
     * Called when the user scans a prescription photo or an e-prescription code.
     * Flutter decides whether the SDK continues with its default handling.
     *
     * Equivalent to iOS: didScanPrescription / didScanEPrescription
     */
    override suspend fun onRedeemPrescriptionEvent(event: RedeemPrescriptionEvent): RedeemPrescriptionDecision {
        val (method, arguments) = when (event) {
            is RedeemPrescriptionEvent.PrescriptionPhotoScanned ->
                "prescriptionPhotoScanned" to mapOf("imageData" to event.imageData)
            is RedeemPrescriptionEvent.EPrescriptionScanned ->
                "ePrescriptionScanned" to mapOf("rawCode" to event.rawCode, "urls" to event.urls)
        }

        // Method channel calls must be made on the main thread.
        return withContext(Dispatchers.Main) {
            suspendCoroutine { continuation ->
                channel.invokeMethod(
                    method,
                    arguments,
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            val response = result as? Map<*, *>
                            val decision = when (response?.get("decision")) {
                                "handled" -> RedeemPrescriptionDecision.Handled
                                "error" -> RedeemPrescriptionDecision.Error(response["message"] as? String ?: "")
                                else -> RedeemPrescriptionDecision.PerformDefault
                            }
                            continuation.resume(decision)
                        }

                        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                            // On error, let SDK handle
                            continuation.resume(RedeemPrescriptionDecision.PerformDefault)
                        }

                        override fun notImplemented() {
                            // Not implemented, let SDK handle
                            continuation.resume(RedeemPrescriptionDecision.PerformDefault)
                        }
                    }
                )
            }
        }
    }
}
