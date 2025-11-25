allprojects {
    repositories {
        google()
        mavenCentral()
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
