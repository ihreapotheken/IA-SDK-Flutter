package de.ihreapotheken.appsdk.flutter.card_link.methods

import android.app.Activity
import de.ihreapotheken.appsdk.flutter.card_link.events.CardLinkEventSender
import de.ihreapotheken.appsdk.flutter.card_link.listeners.CardLinkListenerImpl
import de.ihreapotheken.appsdk.flutter.card_link.models.ConsentStatusMapper
import de.ihreapotheken.appsdk.flutter.card_link.models.EnvironmentMapper
import de.ihreapotheken.sdk.cardlink.api.CardLink
import de.ihreapotheken.sdk.cardlink.api.CardLinkConfig
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class LaunchHandler(
    private val activityProvider: () -> Activity?,
    private val eventSender: CardLinkEventSender
) {
    companion object {
        private const val GUEST_USER_ID = "guest_user_id"
    }

    fun handle(call: MethodCall, result: Result) {
        val sdkApiKey = call.argument<String>("sdkApiKey")
        if (sdkApiKey == null) {
            result.error("MISSING_API_KEY", "SDK API key is required", null)
            return
        }

        val pharmacyId = call.argument<String>("pharmacyId")
        if (pharmacyId == null) {
            result.error("MISSING_PHARMACY_ID", "Pharmacy ID is required", null)
            return
        }

        val phoneNumber = call.argument<String>("phoneNumber")
        if (phoneNumber == null) {
            result.error("MISSING_PHONE_NUMBER", "Phone number is required", null)
            return
        }

        val userId = call.argument<String>("userId") ?: GUEST_USER_ID
        val savedCardName = call.argument<String>("cardName")
        val canCode = call.argument<String>("canCode")
        val consentStatus = ConsentStatusMapper.fromString(call.argument<String>("consentStatus") ?: "SHOW_CONSENT")
        val saveCardEnabled = call.argument<Boolean>("saveCardEnabled") ?: true
        val primaryColor = (call.argument<Any>("primaryColor") as? Number)?.toInt()
        val buttonsColor = (call.argument<Any>("buttonsColor") as? Number)?.toInt()
        val textLinkColor = (call.argument<Any>("textLinkColor") as? Number)?.toInt()
        val bottomNavigationColor = (call.argument<Any>("bottomNavigationColor") as? Number)?.toInt()
        val cardLinkSdkEnvironment = EnvironmentMapper.fromString(call.argument<String>("environment"))
        val applicationId = call.argument<String>("appId")
        val coreAppLogFileURL = call.argument<String>("coreAppLogFileURL")

        val flowType = call.argument<String>("flowType") ?: "launchCardLinkSdk"

        val listener = CardLinkListenerImpl(phoneNumber, eventSender)

        val config = CardLinkConfig(
            sdkApiKey = sdkApiKey,
            pharmacyId = pharmacyId,
            userId = userId,
            savedCardName = savedCardName,
            canCode = canCode,
            phoneNumber = phoneNumber,
            consentStatus = consentStatus,
            saveCardEnabled = saveCardEnabled,
            primaryColor = primaryColor,
            buttonsColor = buttonsColor,
            textLinkColor = textLinkColor,
            bottomNavigationColor = bottomNavigationColor,
            cardLinkSdkEnvironment = cardLinkSdkEnvironment,
            listener = listener,
            applicationId = applicationId,
            hostAppLogFilePath = coreAppLogFileURL,
        )

        activityProvider()?.let { activity ->
            if (flowType == "launchCardLinkCards") {
                CardLink.startMyCards(activity, config)
            } else {
                CardLink.startCardLink(activity, config)
            }
            result.success(null)
        } ?: result.error("NO_ACTIVITY", "Activity not available", null)
    }
}
