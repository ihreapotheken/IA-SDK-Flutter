package de.ihreapotheken.appsdk_v2_flutter_plugin.sdk

import androidx.lifecycle.MutableLiveData
import de.ihreapotheken.sdk.core.api.listener.CartListener
import de.ihreapotheken.sdk.core.api.listener.CheckoutListener
import de.ihreapotheken.sdk.integrations.api.view.IaScreen
import de.ihreapotheken.sdk.integrations.api.view.SdkNavigationTarget
import io.flutter.plugin.common.MethodChannel
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
) : CartListener, CheckoutListener {

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
        // Convert navigation target to string
        val navigationTargetString: String = when (target) {
            IaScreen.CartScreen -> "cart"
            IaScreen.PharmacyScreen -> "pharmacyDetails"
            IaScreen.ThankYouScreen -> "thankYou"
            IaScreen.StartScreen -> "start"
            IaScreen.SearchScreen -> "search"
            // Note: iOS has imprint, hostAppPrivacyPolicy, apofinder
            // but Android SDK doesn't have them yet
            else -> return false // Unknown target, let SDK handle
        }

        val handledByHost = suspendCoroutine { continuation ->
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
        val arguments = mapOf(
            "totalAmountInCart" to totalItems,
            "clientOrderIDs" to emptyList<String>() // TODO: Get actual clientOrderIDs if available
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

        // Send callback to Flutter
        val arguments = mapOf(
            "orderCode" to sdkOrderId,
            "clientOrderIDs" to listOf(hostOrderId)
        )

        channel.invokeMethod(
            "orderingDidFinishOrder",
            arguments
        )
    }
}
