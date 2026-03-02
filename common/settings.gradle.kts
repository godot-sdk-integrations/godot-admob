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

val localProperties = java.util.Properties().also { props ->
	rootDir.resolve("local.properties")
		.takeIf { it.exists() }
		?.inputStream()
		?.use { props.load(it) }
}

gradle.extra["libDir"] = localProperties.getProperty("lib.dir")
	?: "${rootDir}/../android/libs"

dependencyResolutionManagement {
	repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
	repositories {
		google()
		mavenCentral()
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
