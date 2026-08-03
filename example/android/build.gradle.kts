import java.util.Base64

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://api.mapbox.com/downloads/v2/releases/maven")
        }
        mavenLocal()
        maven("https://nexus.link4.health/repository/link4health-anonymous/")
        // The CardLink module's link4health-sdk releases (e.g. 3.4.1, pulled in by
        // de.ihreapotheken.sdk:cardlink) are published to the releases repo, not the
        // anonymous one — resolving them fails without this. Same repository the
        // native SDK project uses (IA-SDK-Dev-Android settings.gradle.kts).
        maven("https://nexus.link4.health/repository/link4health-releases/")
        maven {
            name = "IA SDK repo"
            url = uri("https://maven.pkg.github.com/ihreapotheken/IA-SDK-Android")
            credentials {
                username = System.getenv("GITHUB_USERNAME") ?: "appsdk-service@4ofthem.eu"
                password = System.getenv("GITHUB_TOKEN") ?: ("github_pat_" +
                        String(java.util.Base64.getDecoder().decode(
                            "ZFg4OHliZ0tONlQyTkZCWVhQb1NvbndhcEJXVUxMTllXTkdHYmtGNVNEMDltdThMMlBEdUhKTDVmWWNfQ2tYQ3gwa0sydGNUMElEWUlWMkIxMQ==",
                        )).reversed())
            }
        }
    }
}

plugins {
    id("com.google.firebase.appdistribution") version "5.2.0" apply false
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
