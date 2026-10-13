package de.ihreapotheken.appsdk.flutter.card_link.methods

import android.content.Context
import de.ihreapotheken.sdk.cardlink.api.CardLink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext

class DeleteCardHandler(
    private val contextProvider: () -> Context?,
    private val scope: CoroutineScope,
    private val storageMutex: Mutex,
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

        val context = contextProvider()
        if (context == null) {
            result.error("NO_CONTEXT", "Context not available", null)
            return
        }
        scope.launch {
            try {
                // The SDK blocks on encrypted storage, so it runs off the main thread.
                storageMutex.withLock {
                    withContext(Dispatchers.IO) {
                        CardLink.deleteCard(context, cardName, userId)
                    }
                }
                result.success(null)
            } catch (e: Exception) {
                result.error("DELETE_CARD_ERROR", e.localizedMessage, null)
            }
        }
    }
}
