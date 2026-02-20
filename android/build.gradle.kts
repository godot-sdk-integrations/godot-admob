//
// © 2024-present https://github.com/cengiz-pz
//

import com.android.build.gradle.internal.api.LibraryVariantOutputImpl

plugins {
	alias(libs.plugins.android.library)
	alias(libs.plugins.kotlin.android)
	alias(libs.plugins.undercouch.download)
}

apply(from = "${projectDir}/config.gradle.kts")

android {
	namespace = project.extra["pluginPackageName"] as String
	compileSdk = libs.versions.compileSdk.get().toInt()

	buildFeatures {
		buildConfig = true
	}

	defaultConfig {
		minSdk = libs.versions.minSdk.get().toInt()

		manifestPlaceholders["godotPluginName"] = project.extra["pluginName"] as String
		manifestPlaceholders["godotPluginPackageName"] = project.extra["pluginPackageName"] as String
		buildConfigField("String", "GODOT_PLUGIN_NAME", "\"${project.extra["pluginName"]}\"")
	}

	compileOptions {
		sourceCompatibility = JavaVersion.VERSION_17
		targetCompatibility = JavaVersion.VERSION_17
	}

	kotlin {
		compilerOptions {
			jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
		}
	}

	buildToolsVersion = libs.versions.buildTools.get()

	// Force AAR filenames to match original case and format
	libraryVariants.all {
		outputs.all {
			val outputImpl = this as LibraryVariantOutputImpl
			val buildType = name // "debug" or "release"
			outputImpl.outputFileName = "${project.extra["pluginName"]}-$buildType.aar"
		}
	}
}

// Access the library catalog by name ("libs")
val catalog = extensions.getByType<VersionCatalogsExtension>().named("libs")

// Map all library aliases to their actual dependency provider
val androidDependencies = catalog.libraryAliases.map { alias ->
	catalog.findLibrary(alias).get().get()
}

dependencies {
	implementation("godot:godot-lib:${project.extra["godotVersion"]}.${project.extra["releaseType"]}@aar")
	androidDependencies.forEach { 
		println("[DEBUG] Adding Android dependency: $it")
		implementation(it)
	}
}

tasks {
	register<de.undercouch.gradle.tasks.download.Download>("downloadGodotAar") {
		val destFile = file("${rootDir}/../android/libs/${project.extra["godotAarFile"]}")

		src(project.extra["godotAarUrl"] as String)
		dest(destFile)
		overwrite(false)

		onlyIf {
			val exists = destFile.exists() && destFile.length() > 0
			if (exists) {
				println("[GODOT-LIB] File already exists and is non-empty: ${destFile.absolutePath} (${destFile.length()} bytes)")
				println("[GODOT-LIB] Skipping download.")
			} else {
				if (destFile.exists()) {
					println("[GODOT-LIB] File exists but is empty: ${destFile.absolutePath}")
				} else {
					println("[GODOT-LIB] File not found: ${destFile.absolutePath}")
				}
				println("[GODOT-LIB] Proceeding with download...")
			}
			!exists // run task only if file does NOT exist or is empty
		}
	}

	named("preBuild") {
		dependsOn("downloadGodotAar")
	}
}
