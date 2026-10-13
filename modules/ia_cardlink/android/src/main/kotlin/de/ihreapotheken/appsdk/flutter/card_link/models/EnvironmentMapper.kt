package de.ihreapotheken.appsdk.flutter.card_link.models

import de.ihreapotheken.sdk.cardlink.CardLinkSdkEnvironmentType
import de.ihreapotheken.sdk.core.data.EnvironmentType

object EnvironmentMapper {
    /**
     * Maps the Dart environment. Without one, CardLink follows the environment the SDK was
     * initialized with, as on iOS.
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
