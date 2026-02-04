package de.ihreapotheken.appsdk.flutter.card_link.events

import android.app.Activity
import android.os.Handler
import android.os.Looper
import de.ihreapotheken.appsdk.flutter.card_link.models.toMap
import de.ihreapotheken.sdk.cardlink.domain.model.CardLinkSession
import de.ihreapotheken.sdk.cardlink.domain.model.insurancecard.InsuranceCard
import io.flutter.plugin.common.MethodChannel

class CardLinkEventSender(
    private val activityProvider: () -> Activity?,
    private val methodChannelProvider: () -> MethodChannel?
) {
    private val mainHandler = Handler(Looper.getMainLooper())

    fun sendConsentEvent(accepted: Boolean) {
        val status = if (accepted) "accepted" else "declined"
        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkConsentEvent",
                mapOf("status" to status)
            )
        }
    }

    fun sendSessionCreatedEvent(session: CardLinkSession) {
        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkSessionCreated",
                mapOf("session" to session.toMap())
            )
        }
    }

    fun sendPrescriptionsRedeemedEvent(prescriptions: String) {
        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkPrescriptionsRedeemed",
                mapOf("prescriptions" to prescriptions)
            )
        }
    }

    fun sendGoToCartEvent() {
        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkEvent",
                mapOf("event" to "goToCart")
            )
        }
    }

    fun sendOpenTermsAndConditionsEvent() {
        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkEvent",
                mapOf("event" to "openTermsAndConditions")
            )
        }
    }

    fun sendCardSavedEvent(card: InsuranceCard) {
        val formattedCard = listOf(
            mapOf(
                "id" to card.userId,
                "name" to card.userId,
                "canNumber" to card.can,
                "phoneNumber" to card.phoneNumber
            )
        )

        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkEvent",
                mapOf("event" to "cardSaved", "cards" to formattedCard)
            )
        }
    }

    fun sendAnalyticsEvent(analyticEvent: String) {
        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkAnalyticsEvent",
                mapOf("analyticEvent" to analyticEvent)
            )
        }
    }

    fun sendFailedToInitializeEvent() {
        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkEvent",
                mapOf("event" to "failedToInitialize")
            )
        }
    }

    fun sendCardLinkResultEvent(result: String?) {
        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkEvent",
                mapOf("event" to "cardLinkResult", "result" to result)
            )
        }
    }

    fun sendCardLinkCanceledEvent() {
        mainHandler.post {
            methodChannelProvider()?.invokeMethod(
                "cardLinkEvent",
                mapOf("event" to "cardLinkResult", "result" to "canceled")
            )
        }
    }
}
