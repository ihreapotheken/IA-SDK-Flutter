package de.ihreapotheken.appsdk.flutter.card_link.methods

import android.app.Activity
import de.ihreapotheken.sdk.cardlink.api.CardLink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class DeleteCardHandler(
    private val activityProvider: () -> Activity?
) {
    fun handle(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<*, *>
        if (args == null) {
            result.error("INVALID_ARGUMENTS", "Invalid arguments received", null)
            return
        }

        val userId = args["userId"] as? String
        if (userId == null) {
            result.error("MISSING_USER_ID", "userId is required", null)
            return
        }

        val cardName = args["cardName"] as? String
        if (cardName == null) {
            result.error("MISSING_CARD_NAME", "cardName is required", null)
            return
        }

        activityProvider()?.let { activity ->
            CardLink.deleteCard(activity, cardName, userId)
            result.success(null)
        } ?: result.error("NO_ACTIVITY", "Activity not available", null)
    }
}
