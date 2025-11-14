plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

repositories {
    google()
    mavenCentral()
    gradlePluginPortal()
    maven {
        url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
    }
    mavenLocal()
    maven {
        name = "IA SDK repo"
        url = uri("https://maven.pkg.github.com/ihreapotheken/IA-SDK-Android")
        credentials {
            username = System.getenv("GITHUB_USERNAME") ?: "mljubas@4ofthem.eu"
            password = System.getenv("GITHUB_TOKEN")
                ?: "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"
        }
    }
}

android {
    namespace = "com.example.appsdk_v2_flutter_plugin_example"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "de.ihreapotheken.sdk.iasdkdemo.staging"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
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
}

flutter {
    source = "../.."
}
