import java.util.Properties
import java.io.File

val env = Properties()
val envFile = File(rootProject.projectDir, "../.env")
if (envFile.exists()) {
    envFile.inputStream().use { env.load(it) }
}
rootProject.extensions.extraProperties.set("env", env)
allprojects {
    repositories {
        google()
        mavenCentral()
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

