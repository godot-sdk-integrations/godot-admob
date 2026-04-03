//
// © 2024-present https://github.com/cengiz-pz
//

pluginManagement {
    // Make convention plugins from build-logic available during plugin resolution
    includeBuild("build-logic")
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

val localProperties =
    java.util.Properties().also { props ->
        rootDir
            .resolve("local.properties")
            .takeIf { it.exists() }
            ?.inputStream()
            ?.use { props.load(it) }
    }

val buildProperties =
    java.util.Properties().also { props ->
        rootDir
            .resolve("config/build.properties")
            .takeIf { it.exists() }
            ?.inputStream()
            ?.use { props.load(it) }
    }

gradle.extra["libDir"] = localProperties.getProperty("lib.dir")
    ?: "$rootDir/../android/libs"

gradle.extra["godotDir"] = localProperties.getProperty("godot.dir")
    ?: "$rootDir/../ios/godot"

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()

        ivy {
            name = "Node.js"
            url = uri("https://nodejs.org/dist")
            patternLayout {
                artifact("v[revision]/[artifact]-v[revision]-[classifier].[ext]")
            }
            metadataSources {
                artifact()
            }
            content {
                includeGroup("org.nodejs")
            }
        }

        flatDir {
            dirs(gradle.extra["libDir"] as String)
        }
    }
}

rootProject.name = buildProperties.getProperty("gradleProjectName", "godot-plugin")
include(":addon")
include(":android")
include(":ios")

project(":addon").apply {
    projectDir = file("$rootDir/../addon")
    buildFileName = "addon-build.gradle.kts"
}

project(":android").apply {
    projectDir = file("$rootDir/../android")
    buildFileName = "android-build.gradle.kts"
}

project(":ios").apply {
    projectDir = file("$rootDir/../ios")
    buildFileName = "ios-build.gradle.kts"
}
