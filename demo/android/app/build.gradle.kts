plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("org.jetbrains.kotlin.plugin.compose") version "2.2.20"
}

repositories {
    google()
    mavenCentral()
    gradlePluginPortal()
    maven {
        url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
    }
    maven {
        name = "IA SDK repo"
        url = uri("https://maven.pkg.github.com/ihreapotheken/IA-SDK-Android")
        credentials {
            username = System.getenv("GITHUB_USERNAME") ?: ""
            password = System.getenv("GITHUB_TOKEN") ?: ""
        }
    }
}

android {
    namespace = "test.demo.sdkv2.ios"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "test.demo.sdkv2.ios"
        minSdk = 30
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    dependencies {
        val iaDeSdkVersion = "0.0.17-250"
        val iaDeSdkEnv = System.getenv("IA_DE_SDK_ENV")
        val iaDeSdkDeps = listOf(
            "de.ihreapotheken.sdk:integrations",
            "de.ihreapotheken.sdk:otc",
            "de.ihreapotheken.sdk:ordering",
            "de.ihreapotheken.sdk:pharmacy",
            "de.ihreapotheken.sdk:rx",
            "de.ihreapotheken.sdk:apofinder",
        )
        for (dep in iaDeSdkDeps) {
            implementation(dep + (if (iaDeSdkEnv != null) "-$iaDeSdkEnv" else "") + ":$iaDeSdkVersion")
        }
    }
}
dependencies {
    implementation("androidx.wear.compose:compose-material3:1.5.3")
}

flutter {
    source = "../.."
}
