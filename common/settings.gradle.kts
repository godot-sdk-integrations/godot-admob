//
// © 2024-present https://github.com/cengiz-pz
//

pluginManagement {
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

gradle.extra["libDir"] = localProperties.getProperty("lib.dir")
    ?: "$rootDir/../android/libs"

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

rootProject.name = "godot-admob-plugin"
include(":android")
include(":addon")

project(":android").projectDir = file("../android")
project(":addon").projectDir = file("../addon")
