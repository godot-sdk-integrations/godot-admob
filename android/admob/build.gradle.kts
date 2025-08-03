//
// © 2024-present https://github.com/cengiz-pz
//

import java.util.Properties
import org.apache.tools.ant.filters.ReplaceTokens

plugins {
	alias(libs.plugins.android.library)
	alias(libs.plugins.kotlin.android)
	alias(libs.plugins.undercouch.download)
}

apply(from = "${rootDir}/config.gradle.kts")

val props = Properties().apply {
	load(file("../../ios/config/config.properties").inputStream())
}

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
		setProperty("archivesBaseName", project.extra["pluginName"] as String)
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
}

val pluginDependencies = arrayOf(
	libs.androidx.appcompat.get(),
	libs.play.services.ads.get()
)

dependencies {
	implementation("godot:godot-lib:${project.extra["godotVersion"]}.${project.extra["releaseType"]}@aar")
	pluginDependencies.forEach { implementation(it) }
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
			"pluginDependencies" to pluginDependencies.joinToString(", ") { "\"$it\"" },
			"iosFrameworks" to (props.getProperty("frameworks") ?: "")
					.split(",")
					.joinToString(", ") { "\"${it.trim()}\"" },
			"iosEmbeddedFrameworks" to (props.getProperty("embedded_frameworks") ?: "")
					.split(",")
					.joinToString(", ") { "\"${it.trim()}\"" },
			"iosLinkerFlags" to (props.getProperty("flags") ?: "")
					.split(",")
					.joinToString(", ") { "\"${it.trim()}\"" }
		))
	}

	register<de.undercouch.gradle.tasks.download.Download>("downloadGodotAar") {
		src(project.extra["godotAarUrl"] as String)
		dest(file("${project.rootDir}/libs/${project.extra["godotAarFile"]}"))
		overwrite(false)
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
			into("${project.extra["pluginName"]}-root/addons/${project.extra["pluginName"]}")
		}
	}

	named<Delete>("clean") {
		dependsOn("cleanDemoAddons")
	}
}

afterEvaluate {
	listOf("assembleDebug", "assembleRelease").forEach { taskName ->
		tasks.named(taskName).configure {
			finalizedBy("copyAddonsToDemo")
		}
	}
}
