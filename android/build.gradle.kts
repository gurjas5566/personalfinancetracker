allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ No space before ( and no quotes around classpath
        classpath("com.google.gms:google-services:4.4.3")
    }
}

// ✅ Set custom build directory
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// ✅ Update subproject build dirs
subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// ✅ Ensure evaluation order
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Register 'clean' task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
