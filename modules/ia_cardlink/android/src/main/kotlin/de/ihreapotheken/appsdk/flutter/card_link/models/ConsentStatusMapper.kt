package de.ihreapotheken.appsdk.flutter.card_link.models

import de.ihreapotheken.sdk.cardlink.ConsentStatus

object ConsentStatusMapper {
    fun fromString(consentStatus: String): ConsentStatus {
        return when (consentStatus) {
            "SHOW_CONSENT" -> ConsentStatus.SHOW_CONSENT
            "CONSENT_ACCEPTED" -> ConsentStatus.CONSENT_ACCEPTED
            "CONSENT_DECLINED" -> ConsentStatus.CONSENT_DECLINED
            else -> ConsentStatus.SHOW_CONSENT
        }
    }
}
