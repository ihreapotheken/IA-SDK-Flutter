package de.ihreapotheken.appsdk.flutter.card_link

import android.app.Activity
import de.ihreapotheken.appsdk.flutter.card_link.events.CardLinkEventSender
import de.ihreapotheken.appsdk.flutter.card_link.methods.DeleteCardHandler
import de.ihreapotheken.appsdk.flutter.card_link.methods.GetSavedCardsHandler
import de.ihreapotheken.appsdk.flutter.card_link.methods.LaunchHandler
import de.ihreapotheken.sdk.cardlink.CardlinkModule
import de.ihreapotheken.sdk.cardlink.api.CardLink
import de.ihreapotheken.sdk.cardlink.api.REQUEST_CODE_CARD_LINK_ACTIVITY
import de.ihreapotheken.sdk.integrations.api.IaSdk
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** IaSdkFlutterCardLink */
class IaSdkFlutterCardLink :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    private val eventSender by lazy {
        CardLinkEventSender(
            activityProvider = { activity },
            methodChannelProvider = { channel }
        )
    }

    private val launchHandler by lazy {
        LaunchHandler(
            activityProvider = { activity },
            eventSender = eventSender
        )
    }

    private val getSavedCardsHandler by lazy {
        GetSavedCardsHandler(activityProvider = { activity })
    }

    private val deleteCardHandler by lazy {
        DeleteCardHandler(activityProvider = { activity })
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
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener { requestCode, resultCode, data ->
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
    }

    override fun onDetachedFromActivity() {
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
                // TODO: Pass coreAppLogFileURL to CardLink when supported on Android
                launchHandler.handle(call, result)
            }

            "getVersion" -> {
                result.success(null)
            }

            "getEnvironment" -> {
                result.success(null)
            }

            "getLogFilePath" -> {
                activity?.let {
                    val logFilePath = CardLink.getLogFilePath(it)
                    result.success(logFilePath)
                } ?: result.success("")
            }

            "getSavedCards" -> {
                getSavedCardsHandler.handle(call, result)
            }

            "deleteCard" -> {
                deleteCardHandler.handle(call, result)
            }

            "deleteAllCards" -> {
                activity?.let {
                    CardLink.clearAllCardLinkData(it)
                    result.success(null)
                } ?: result.error("NO_ACTIVITY", "Activity not available", null)
            }

            "deleteAllUserRelatedData" -> {
                activity?.let {
                    CardLink.clearAllCardLinkData(it)
                    result.success(null)
                } ?: result.error("NO_ACTIVITY", "Activity not available", null)
            }

            "finish" -> {
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }
}
