package de.ihreapotheken.appsdk.flutter.card_link.methods

import android.app.Activity
import de.ihreapotheken.sdk.cardlink.api.CardLink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class GetSavedCardsHandler(
    private val activityProvider: () -> Activity?
) {
    fun handle(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *>
        if (args == null) {
            result.error("INVALID_ARGUMENTS", "Invalid arguments received", null)
            return
        }

        val userId = args["userId"] as? String ?: ""
        activityProvider()?.let { activity ->
            val cards = CardLink.getSavedCards(activity, userId)
            try {
                val json = Json.encodeToString(cards)
                result.success(json)
            } catch (e: Exception) {
                result.error("ENCODING_ERROR", "Error encoding cards to JSON", e.localizedMessage)
            }
        } ?: result.error("NO_ACTIVITY", "Activity not available", null)
    }
}
