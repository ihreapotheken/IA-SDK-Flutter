pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
        }
        mavenLocal()
        maven("https://nexus.link4.health/repository/link4health-anonymous/")
        maven {
            name = "IA SDK repo"
            url = uri("https://maven.pkg.github.com/ihreapotheken/IA-SDK-Android")
            credentials {
                username = System.getenv("GITHUB_USERNAME") ?: "mljubas@4ofthem.eu"
                password = System.getenv("GITHUB_TOKEN") ?: "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"
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.12.3" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
