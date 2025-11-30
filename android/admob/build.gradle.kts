//
// © 2024-present https://github.com/cengiz-pz
//

import com.android.build.gradle.internal.api.LibraryVariantOutputImpl

import org.apache.tools.ant.filters.ReplaceTokens

import java.util.Properties
import java.io.FileInputStream


plugins {
	alias(libs.plugins.android.library)
	alias(libs.plugins.kotlin.android)
	alias(libs.plugins.undercouch.download)
}

apply(from = "${rootDir}/config.gradle.kts")

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
	register<Copy>("copyDebugAARToDemoAddons") {
		description = "Copies the generated debug AAR binary to the plugin's addons directory"
		from("build/outputs/aar")
		include("${project.extra["pluginName"]}-debug.aar")
		into("${project.extra["demoAddOnsDirectory"]}/${project.extra["pluginName"]}/bin/debug")
	}

	register<Copy>("copyReleaseAARToDemoAddons") {
		description = "Copies the generated release AAR binary to the plugin's addons directory"
		from("build/outputs/aar")
		include("${project.extra["pluginName"]}-release.aar")
		into("${project.extra["demoAddOnsDirectory"]}/${project.extra["pluginName"]}/bin/release")
	}

	register<Delete>("cleanDemoAddons") {
		delete("${project.extra["demoAddOnsDirectory"]}/${project.extra["pluginName"]}")
	}

	register<Copy>("copyPngsToDemo") {
		description = "Copies the PNG images to the plugin's addons directory"
		from(project.extra["templateDirectory"] as String)
		into("${project.extra["demoAddOnsDirectory"]}/${project.extra["pluginName"]}")
		include("**/*.png")
	}

	register<Copy>("copyAddonsToDemo") {
		description = "Copies the export scripts templates to the plugin's addons directory"
		dependsOn("cleanDemoAddons")
		finalizedBy("copyDebugAARToDemoAddons", "copyReleaseAARToDemoAddons", "copyPngsToDemo")

		from(project.extra["templateDirectory"] as String)
		into("${project.extra["demoAddOnsDirectory"]}/${project.extra["pluginName"]}")
		include("**/*.gd")
		include("**/*.cfg")
		filter<ReplaceTokens>("tokens" to mapOf(
			"pluginName" to (project.extra["pluginName"] as String),
			"pluginNodeName" to (project.extra["pluginNodeName"] as String),
			"pluginVersion" to (project.extra["pluginVersion"] as String),
			"pluginPackage" to (project.extra["pluginPackageName"] as String),
			"androidDependencies" to androidDependencies.joinToString(", ") { "\"$it\"" },
			"iosPlatformVersion" to (project.extra["iosPlatformVersion"] as String),
			"iosFrameworks" to (project.extra["iosFrameworks"] as String)
				.split(",")
				.map { it.trim() }
				.filter { it.isNotBlank() }
				.joinToString(", ") { "\"$it\"" },
			"iosEmbeddedFrameworks" to (project.extra["iosEmbeddedFrameworks"] as String)
				.split(",")
				.map { it.trim() }
				.filter { it.isNotBlank() }
				.joinToString(", ") { "\"$it\"" },
			"iosLinkerFlags" to (project.extra["iosLinkerFlags"] as String)
				.split(",")
				.map { it.trim() }
				.filter { it.isNotBlank() }
				.joinToString(", ") { "\"$it\"" }
		))
	}

	register("replaceMediationTokens") {
		description = "Replaces mediation tokens in MediationNetwork.gd with values from mediation.properties"
		dependsOn("copyAddonsToDemo")

		doLast {
			// Load properties file
			val mediationProps = Properties().apply {
				load(FileInputStream(file("${rootDir}/../common/mediation.properties")))
			}

			// Setup files and content
			val gdFile = file("${project.extra["demoAddOnsDirectory"]}/${project.extra["pluginName"]}/model/MediationNetwork.gd")
			if (!gdFile.exists()) {
				println("[WARNING] MediationNetwork.gd not found at ${gdFile.absolutePath}, skipping replacement.")
				return@doLast
			}

			// Read raw file content with tokens
			val content = gdFile.readText()
			var newContent = content

			val networks = mediationProps.stringPropertyNames()
				.filter { it.contains(".") }
				.map { it.substringBefore(".") }
				.distinct()
				.sorted()

			for (network in networks) {
				// Prepare replacements
				val depsStr = mediationProps.getProperty("${network}.dependencies") ?: ""
				val deps = if (depsStr.isNotEmpty()) {
					depsStr.split(",").map { "\"${it.trim()}\"" }.joinToString(", ")
				} else {
					""
				}
				val repo = mediationProps.getProperty("${network}.mavenRepo") ?: ""
				val andAdapter = mediationProps.getProperty("${network}.androidAdapterClass") ?: ""
				val iosAdapter = mediationProps.getProperty("${network}.iosAdapterClass") ?: ""
				val pod = mediationProps.getProperty("${network}.pod") ?: ""
				val podVer = mediationProps.getProperty("${network}.podVersion") ?: ""
				val skIdsStr = mediationProps.getProperty("${network}.skAdNetworkIds") ?: ""
				val skIds = if (skIdsStr.isNotEmpty()) {
					skIdsStr.split(",").map { "\"${it.trim()}\"" }.joinToString(", ")
				} else {
					""
				}

				// Replace tokens
				newContent = newContent
					.replace("@${network}Dependencies@", deps)
					.replace("@${network}MavenRepo@", repo)
					.replace("@${network}AndroidAdapterClass@", andAdapter)
					.replace("@${network}IosAdapterClass@", iosAdapter)
					.replace("@${network}Pod@", pod)
					.replace("@${network}PodVersion@", podVer)
					.replace("@${network}SkAdNetworkIds@", skIds)
			}

			// Write updated content with tokens replaced
			gdFile.writeText(newContent)
			println("[INFO] Mediation tokens replaced in ${gdFile.absolutePath}")
		}
	}

	register<de.undercouch.gradle.tasks.download.Download>("downloadGodotAar") {
		val destFile = file("${project.rootDir}/libs/${project.extra["godotAarFile"]}")

		src(project.extra["godotAarUrl"] as String)
		dest(destFile)
		overwrite(false)

		onlyIf {
			val exists = destFile.exists() && destFile.length() > 0
			if (exists) {
				println("[DEBUG] File already exists and is non-empty: ${destFile.absolutePath} (${destFile.length()} bytes)")
				println("[DEBUG] Skipping download.")
			} else {
				if (destFile.exists()) {
					println("[DEBUG] File exists but is empty: ${destFile.absolutePath}")
				} else {
					println("[DEBUG] File not found: ${destFile.absolutePath}")
				}
				println("[DEBUG] Proceeding with download...")
			}
			!exists // run task only if file does NOT exist or is empty
		}
	}

	named("preBuild") {
		dependsOn("downloadGodotAar")
	}

	register<Zip>("packageDistribution") {
		archiveFileName.set("${project.extra["pluginArchive"]}")
		destinationDirectory.set(layout.buildDirectory.dir("dist"))
		exclude("**/*.uid")
		exclude("**/*.import")
		from("${project.extra["demoAddOnsDirectory"]}/${project.extra["pluginName"]}") {
			into("addons/${project.extra["pluginName"]}")
		}
		doLast {
			println("Zip archive created at: ${archiveFile.get().asFile.path}")
		}
	}

	named<Delete>("clean") {
		dependsOn("cleanDemoAddons")
	}
}

afterEvaluate {
	listOf("assembleDebug", "assembleRelease").forEach { taskName ->
		tasks.named(taskName).configure {
			finalizedBy("copyAddonsToDemo", "replaceMediationTokens")
		}
	}
}
