package de.ihreapotheken.appsdk.flutter.card_link.models

import de.ihreapotheken.sdk.cardlink.CardLinkSdkEnvironmentType
import de.ihreapotheken.sdk.core.domain.model.EnvironmentType

object EnvironmentMapper {
    /**
     * Without an environment, CardLink follows the environment the SDK was initialized with.
     */
    fun fromString(environment: String?): CardLinkSdkEnvironmentType {
        return when (environment) {
            "DEBUG" -> CardLinkSdkEnvironmentType.DEBUG
            "PRODUCTION" -> CardLinkSdkEnvironmentType.PRODUCTION
            else -> when (EnvironmentType.current()) {
                EnvironmentType.PROD -> CardLinkSdkEnvironmentType.PRODUCTION
                EnvironmentType.DEV, EnvironmentType.STAGING -> CardLinkSdkEnvironmentType.DEBUG
            }
        }
    }
}
