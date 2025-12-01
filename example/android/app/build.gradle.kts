import com.google.firebase.appdistribution.gradle.firebaseAppDistribution
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.firebase.appdistribution")
}

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
            username = System.getenv("GITHUB_USERNAME") ?: "appsdk-service@4ofthem.eu"
            password = System.getenv("GITHUB_TOKEN") ?: "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"
        }
    }
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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
        applicationId = "de.ihreapotheken.sdk.iasdkdemo.staging" // applicationId = "de.ihreapotheken.flutter"
        minSdk = 30
        targetSdk = 36
        versionName = System.getenv("APP_SDK_BUILD_VERSION") ?: "1.0.0"
        versionCode = if (System.getenv("APP_SDK_BUILD_NUMBER") == null) {
            1
        } else {
            Integer.parseInt(System.getenv("APP_SDK_BUILD_NUMBER"))
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { rootProject.file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            firebaseAppDistribution {
                appId = "1:805028679903:android:a66b4f3fd9dba27124d96a"
                artifactType = "APK"
                artifactPath = rootProject.file("../build/app/outputs/apk/release/app-release.apk").path
                serviceCredentialsFile = rootProject.file("fb-distribution-service-credentials.json").path
                testers = arrayOf(
                    "cvitaman@gmail.com",
                    "4ot.testing@gmail.com",
                    "julia.schindel@ihreapotheken.de",
                    "lorenathiel2@gmail.com",
                    "testproduktmanagement@gmail.com"
                ).joinToString( ", ")
            }
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

flutter {
    source = "../.."
}
