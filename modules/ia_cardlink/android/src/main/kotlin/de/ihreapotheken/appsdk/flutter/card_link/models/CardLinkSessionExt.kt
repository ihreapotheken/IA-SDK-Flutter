package de.ihreapotheken.appsdk.flutter.card_link.models

import de.ihreapotheken.sdk.cardlink.domain.model.CardLinkSession

fun CardLinkSession.toMap(): Map<String, Any> {
    return mapOf(
        "cardSessionId" to cardSessionId,
        "sessionExpireTimestamp" to sessionExpireTimestamp
    )
}
