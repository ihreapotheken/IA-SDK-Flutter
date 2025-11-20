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
                username = System.getenv("GITHUB_USERNAME") ?: "mljubas@4ofthem.eu"
                password = System.getenv("GITHUB_TOKEN") ?: "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"
            }
        }
    }
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
