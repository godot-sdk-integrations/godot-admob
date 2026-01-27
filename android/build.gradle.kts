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

val androidDependencies = arrayOf(
	libs.androidx.appcompat.get(),
	libs.androidx.lifecycle.get(),
	libs.play.services.ads.get()
)

dependencies {
	implementation("godot:godot-lib:${project.extra["godotVersion"]}.${project.extra["releaseType"]}@aar")
	androidDependencies.forEach { implementation(it) }
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
				println("[godot-lib] File already exists and is non-empty: ${destFile.absolutePath} (${destFile.length()} bytes)")
				println("[godot-lib] Skipping download.")
			} else {
				if (destFile.exists()) {
					println("[godot-lib] File exists but is empty: ${destFile.absolutePath}")
				} else {
					println("[godot-lib] File not found: ${destFile.absolutePath}")
				}
				println("[godot-lib] Proceeding with download...")
			}
			!exists // run task only if file does NOT exist or is empty
		}
	}

	named("preBuild") {
		dependsOn("downloadGodotAar")
	}
}
