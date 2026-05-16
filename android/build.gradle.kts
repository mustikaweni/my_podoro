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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
subprojects {
    val fixProject = Action<Project> {
        if (extensions.findByName("android") != null) {
            val android = extensions.getByName("android") as com.android.build.gradle.BaseExtension
            
            try {
                android.compileSdkVersion(36)
            } catch (e: Exception) { }

            if (android.namespace == null) {
                android.namespace = "dev.isar.${name.replace("-", "_")}"
            }
        }
    }

    if (state.executed) {
        fixProject.execute(this)
    } else {
        afterEvaluate { fixProject.execute(this) }
    }
}
