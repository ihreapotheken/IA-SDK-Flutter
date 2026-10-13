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
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class GetSavedCardsHandler(
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

        val userId = args["userId"] as? String ?: ""
        val context = contextProvider()
        if (context == null) {
            result.error("NO_CONTEXT", "Context not available", null)
            return
        }
        scope.launch {
            try {
                // The SDK blocks on encrypted storage, so it runs off the main thread.
                val json = storageMutex.withLock {
                    withContext(Dispatchers.IO) {
                        Json.encodeToString(CardLink.getSavedCards(context, userId))
                    }
                }
                result.success(json)
            } catch (e: Exception) {
                result.error("ENCODING_ERROR", "Error reading or encoding the saved cards", e.localizedMessage)
            }
        }
    }
}
