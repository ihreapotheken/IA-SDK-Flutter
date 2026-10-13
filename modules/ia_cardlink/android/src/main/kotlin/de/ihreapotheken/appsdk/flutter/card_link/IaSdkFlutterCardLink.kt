package de.ihreapotheken.appsdk.flutter.card_link

import android.app.Activity
import android.content.Context
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import de.ihreapotheken.appsdk.flutter.card_link.events.CardLinkEventSender
import de.ihreapotheken.appsdk.flutter.card_link.methods.DeleteCardHandler
import de.ihreapotheken.appsdk.flutter.card_link.methods.GetSavedCardsHandler
import de.ihreapotheken.appsdk.flutter.card_link.methods.LaunchHandler
import de.ihreapotheken.sdk.cardlink.BuildConfig
import de.ihreapotheken.sdk.cardlink.CardLinkSdkEnvironment
import de.ihreapotheken.sdk.cardlink.HostAppLogProvider
import de.ihreapotheken.sdk.cardlink.CardlinkModule
import de.ihreapotheken.sdk.cardlink.api.CardLink
import de.ihreapotheken.sdk.cardlink.api.REQUEST_CODE_CARD_LINK_ACTIVITY
import de.ihreapotheken.sdk.core.api.featureproviders.SavedCardData
import de.ihreapotheken.sdk.integrations.api.IaSdk
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext

/** IaSdkFlutterCardLink */
class IaSdkFlutterCardLink :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var applicationContext: Context? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var activityLifecycle: Lifecycle? = null

    /**
     * Scope for the SDK's storage calls, which block and therefore run on the IO dispatcher.
     */
    private val scope = MainScope()

    /**
     * Whether CardLink was launched and hasn't covered the host activity yet. The SDK signs in before
     * it opens its screen, and doesn't open it when that fails.
     */
    private var isCardLinkLaunching = false

    /**
     * Whether a CardLink screen launched by this plugin covers the host activity. The Android SDK has
     * no exit callback, so its closing is detected when the host activity resumes.
     */
    private var isCardLinkShown = false

    private val lifecycleObserver = LifecycleEventObserver { _, event ->
        when (event) {
            Lifecycle.Event.ON_PAUSE -> if (isCardLinkLaunching) {
                isCardLinkLaunching = false
                isCardLinkShown = true
            }
            Lifecycle.Event.ON_RESUME -> if (isCardLinkShown) {
                isCardLinkShown = false
                eventSender.sendWillExitEvent()
            }
            else -> Unit
        }
    }

    /**
     * Serializes the SDK's storage calls: its card storage isn't safe to create from two threads at once.
     */
    private val storageMutex = Mutex()

    private val activityResultListener = PluginRegistry.ActivityResultListener { requestCode, resultCode, data ->
        if (requestCode == REQUEST_CODE_CARD_LINK_ACTIVITY) {
            if (resultCode == Activity.RESULT_OK) {
                val message = data?.getStringExtra("card_link_result")
                eventSender.sendCardLinkResultEvent(message)
            } else if (resultCode == Activity.RESULT_CANCELED) {
                eventSender.sendCardLinkCanceledEvent()
            }
            true
        } else {
            false
        }
    }

    /**
     * The SDK's storage calls accept any context, so they work before an activity is attached.
     */
    private fun storageContext(): Context? = activity ?: applicationContext

    private val eventSender by lazy {
        CardLinkEventSender(
            activityProvider = { activity },
            methodChannelProvider = { channel }
        )
    }

    private val launchHandler by lazy {
        LaunchHandler(
            activityProvider = { activity },
            eventSender = eventSender,
            onLaunched = { isCardLinkLaunching = true },
            onFailedToInitialize = { isCardLinkLaunching = false },
        )
    }

    private val getSavedCardsHandler by lazy {
        GetSavedCardsHandler(contextProvider = ::storageContext, scope = scope, storageMutex = storageMutex)
    }

    private val deleteCardHandler by lazy {
        DeleteCardHandler(contextProvider = ::storageContext, scope = scope, storageMutex = storageMutex)
    }

    companion object {
        private const val CHANNEL_ID = "de.ihreapotheken/sdk/cardLink"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            CHANNEL_ID
        )
        channel.setMethodCallHandler(this)
        applicationContext = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addActivityResultListener(activityResultListener)
        // FlutterActivity and FlutterFragmentActivity are lifecycle owners.
        activityLifecycle = (binding.activity as? LifecycleOwner)?.lifecycle?.also {
            it.addObserver(lifecycleObserver)
        }
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(activityResultListener)
        activityLifecycle?.removeObserver(lifecycleObserver)
        activityBinding = null
        activityLifecycle = null
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "register" -> {
                IaSdk.register(CardlinkModule)
                result.success(null)
            }

            "launch" -> {
                launchHandler.handle(call, result)
            }

            "getVersion" -> {
                result.success(BuildConfig.SDK_VERSION)
            }

            "getEnvironment" -> {
                result.success(CardLinkSdkEnvironment.cardLinkSdkEnvironment.name)
            }

            "getLogFilePath" -> {
                val context = storageContext()
                if (context == null) {
                    result.error("NO_CONTEXT", "Context not available", null)
                    return
                }
                result.success(CardLink.getLogFilePath(context))
            }

            "getSavedCards" -> {
                getSavedCardsHandler.handle(call, result)
            }

            "deleteCard" -> {
                deleteCardHandler.handle(call, result)
            }

            "setHostAppLogFilePath" -> {
                val path = call.argument<String>("path")
                if (path == null) {
                    result.error("INVALID_ARGUMENTS", "path is required", null)
                    return
                }
                HostAppLogProvider.initialize(path.ifEmpty { null })
                result.success(null)
            }

            "updateCard" -> {
                val userId = call.argument<String>("userId")
                val originalName = call.argument<String>("originalName")
                val name = call.argument<String>("name")
                val phoneNumber = call.argument<String>("phoneNumber")
                val canCode = call.argument<String>("canCode")
                if (userId == null || originalName == null || name == null || phoneNumber == null || canCode == null) {
                    result.error(
                        "INVALID_ARGUMENTS",
                        "userId, originalName, name, phoneNumber and canCode are required",
                        null,
                    )
                    return
                }
                runStorageCall(result) { context ->
                    CardLink.updateCard(
                        context,
                        originalName,
                        SavedCardData(
                            name = name,
                            phoneNumber = phoneNumber,
                            canCode = canCode,
                            userId = userId,
                        ),
                    )
                }
            }

            "reorderSavedCards" -> {
                val userId = call.argument<String>("userId")
                val orderedCanCodes = call.argument<List<*>>("orderedCanCodes")?.filterIsInstance<String>()
                if (userId == null || orderedCanCodes == null) {
                    result.error("INVALID_ARGUMENTS", "userId and orderedCanCodes are required", null)
                    return
                }
                runStorageCall(result) { context ->
                    CardLink.reorderSavedCards(context, orderedCanCodes, userId)
                }
            }

            "deleteAllCards", "deleteAllUserRelatedData" -> {
                runStorageCall(result) { context ->
                    CardLink.clearAllCardLinkData(context)
                }
            }

            "finish" -> {
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Runs a blocking SDK storage call off the main thread and reports its completion to Flutter.
     */
    private fun runStorageCall(result: Result, block: (Context) -> Unit) {
        val context = storageContext()
        if (context == null) {
            result.error("NO_CONTEXT", "Context not available", null)
            return
        }
        scope.launch {
            try {
                storageMutex.withLock {
                    withContext(Dispatchers.IO) {
                        block(context)
                    }
                }
                result.success(null)
            } catch (e: Exception) {
                result.error("STORAGE_ERROR", e.localizedMessage, null)
            }
        }
    }
}
