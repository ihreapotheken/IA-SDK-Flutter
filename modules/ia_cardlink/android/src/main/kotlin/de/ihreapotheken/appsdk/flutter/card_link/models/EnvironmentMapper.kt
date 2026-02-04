package de.ihreapotheken.appsdk.flutter.card_link.models

import de.ihreapotheken.sdk.cardlink.CardLinkSdkEnvironmentType

object EnvironmentMapper {
    fun fromString(environment: String?): CardLinkSdkEnvironmentType {
        return when (environment) {
            "DEBUG" -> CardLinkSdkEnvironmentType.DEBUG
            "PRODUCTION" -> CardLinkSdkEnvironmentType.PRODUCTION
            else -> CardLinkSdkEnvironmentType.PRODUCTION
        }
    }
}
