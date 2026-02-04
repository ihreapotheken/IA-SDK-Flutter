package de.ihreapotheken.appsdk.flutter.card_link.listeners

import de.ihreapotheken.appsdk.flutter.card_link.events.CardLinkEventSender
import de.ihreapotheken.sdk.cardlink.CardLinkListener
import de.ihreapotheken.sdk.cardlink.domain.model.CardLinkSession
import de.ihreapotheken.sdk.cardlink.domain.model.insurancecard.InsuranceCard

class CardLinkListenerImpl(
    private val phoneNumber: String,
    private val eventSender: CardLinkEventSender
) : CardLinkListener {

    override fun onConsentAccepted(setPhoneNumber: (String) -> Unit) {
        setPhoneNumber(phoneNumber)
        eventSender.sendConsentEvent(accepted = true)
    }

    override fun onConsentDeclined() {
        eventSender.sendConsentEvent(accepted = false)
    }

    override fun onSessionCreated(session: CardLinkSession) {
        eventSender.sendSessionCreatedEvent(session)
    }

    override fun onPrescriptionsRedeemed(prescriptions: String) {
        eventSender.sendPrescriptionsRedeemedEvent(prescriptions)
    }

    override fun onGoToCart() {
        eventSender.sendGoToCartEvent()
    }

    override fun openTermsAndConditions() {
        eventSender.sendOpenTermsAndConditionsEvent()
    }

    override fun onSaveHealthCard(card: InsuranceCard) {
        eventSender.sendCardSavedEvent(card)
    }

    override fun reportAnalytics(analyticEvent: String) {
        eventSender.sendAnalyticsEvent(analyticEvent)
    }

    override fun failedToInitializeCardlink() {
        eventSender.sendFailedToInitializeEvent()
    }
}
