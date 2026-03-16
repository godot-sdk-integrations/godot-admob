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

val configProperties =
    java.util.Properties().also { props ->
        rootDir
            .resolve("config/config.properties")
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

rootProject.name = configProperties.getProperty("gradleProjectName", "godot-plugin")
include(":addon")
include(":android")
include(":ios")

project(":addon").projectDir = file("../addon")
project(":android").projectDir = file("../android")
project(":ios").projectDir = file("../ios")
