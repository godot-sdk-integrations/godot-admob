//
// © 2026-present https://github.com/cengiz-pz
//

import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

plugins {
	alias(libs.plugins.android.library) apply false
	alias(libs.plugins.kotlin.android) apply false
	alias(libs.plugins.undercouch.download) apply false
}

allprojects {
	tasks.withType<JavaCompile> {
		options.compilerArgs.add("-Xlint:unchecked")
		options.compilerArgs.add("-Xlint:deprecation")
	}
}

// Load configuration from project root
apply(from = "${rootDir}/config.gradle.kts")

tasks {
	register<Copy>("buildAndroidDebug") {
		description = "Copies the generated GDScript and debug AAR binary to the plugin directory"

		dependsOn(":addon:generateGDScript")
		dependsOn(":addon:copyAssets")
		dependsOn(":android:assembleDebug")

		into("${project.extra["pluginDir"]}/android")

		from("${rootDir}/../addon/build/output") {
			include("addons/${project.extra["pluginName"]}/**")
		}

		from("${rootDir}/../android/build/outputs/aar") {
			include("${project.extra["pluginName"]}-debug.aar")
			into("addons/${project.extra["pluginName"]}/bin/debug")
		}

		doLast {
			val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
			val current = LocalDateTime.now().format(formatter)
			println("Android debug build completed at: $current")
		}
	}

	register<Copy>("buildAndroidRelease") {
		description = "Copies the generated GDScript and release AAR binary to the plugin directory"

		dependsOn(":addon:generateGDScript")
		dependsOn(":addon:copyAssets")
		dependsOn(":android:assembleRelease")

		into("${project.extra["pluginDir"]}/android")

		from("${rootDir}/../addon/build/output") {
			include("addons/${project.extra["pluginName"]}/**")
		}

		from("${rootDir}/../android/build/outputs/aar") {
			include("${project.extra["pluginName"]}-release.aar")
			into("addons/${project.extra["pluginName"]}/bin/release")
		}

		doLast {
			val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
			val current = LocalDateTime.now().format(formatter)
			println("Android release build completed at: $current")
		}
	}

	register("buildAndroid") {
		description = "Builds both debug and release"

		dependsOn("buildAndroidDebug")
		dependsOn("buildAndroidRelease")
	}

	register<Exec>("resolveSPMPackages") {
		inputs.files(fileTree("${rootDir}/../ios/config"))

		outputs.dir("${rootDir}/../ios/${project.extra["pluginModuleName"]}_plugin.xcodeproj")

		val scriptDir = file("${rootDir}/../script")
		commandLine("bash", "${scriptDir}/build_ios.sh", "-P")
		environment("INVOKED_BY_GRADLE", "true")
	}

	register<Exec>("buildiOS") {
		dependsOn(project(":addon").tasks.named("generateGDScript"))
		dependsOn(project(":addon").tasks.named("generateiOSConfig"))
		dependsOn(project(":addon").tasks.named("copyAssets"))
		dependsOn("resolveSPMPackages")

		inputs.files(project(":addon").tasks.named("generateGDScript").map { it.outputs.files })
		inputs.files(project(":addon").tasks.named("generateiOSConfig").map { it.outputs.files })
		inputs.files(project(":addon").tasks.named("copyAssets").map { it.outputs.files })

		inputs.dir("${rootDir}/../ios/src")
		inputs.files(fileTree("${rootDir}/config"))
		inputs.files(fileTree("${rootDir}/../ios/config"))

		outputs.dir("${rootDir}/../ios/build/framework")

		finalizedBy("copyiOSBuildArtifacts")

		val scriptDir = file("${rootDir}/../script")
		commandLine("bash", "${scriptDir}/build_ios.sh", "-b")
		environment("INVOKED_BY_GRADLE", "true")

		doLast {
			val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
			val current = LocalDateTime.now().format(formatter)
			println("iOS build completed at: $current")
		}
	}

	register<Copy>("copyiOSBuildArtifacts") {
		description = "Copies iOS build artifacts (xcframeworks and addon files) to the plugin directory"

		dependsOn(":addon:copyAssets")
		dependsOn(":addon:generateGDScript")
		mustRunAfter("buildiOS")

		val pluginName = project.extra["pluginName"] as String
		val iosDir = file(project.extra["iosDir"] as String)
		val buildDir = iosDir.resolve("build")
		val artifactsDir = buildDir.resolve("DerivedData/ios_release/SourcePackages/artifacts")
		val frameworkDir = buildDir.resolve("framework")
		val pluginDir = file(project.extra["pluginDir"] as String)

		val destDir = pluginDir.resolve("ios")
		destinationDir = destDir

		doFirst {
			delete(destDir)

			if (!artifactsDir.exists()) {
				println("Warning: '${artifactsDir.path}' not found. Skipping framework directory.")
			} else {
				val xcframeworks = artifactsDir
					.walkTopDown()
					.filter { it.isDirectory && it.name.endsWith(".xcframework", ignoreCase = true) }
					.toList()
				if (xcframeworks.isEmpty()) {
					println("Warning: No .xcframework items found in ${artifactsDir.path}. Skipping framework directory.")
				} else {
					xcframeworks.forEach { println("Copying third-party framework: ${it.name}") }
					println("Frameworks found in ${artifactsDir.path}. Creating destination directory...")
				}
			}
			for (variant in listOf("release", "debug")) {
				val xcfw = frameworkDir.resolve("${pluginName}.${variant}.xcframework")
				if (xcfw.exists()) {
					println("Copying plugin framework: ${xcfw.path}")
				} else {
					println("Warning: Expected xcframework not found, skipping: ${xcfw.path}")
				}
			}
		}

		// Skip whole task if no iOS build output
		onlyIf { frameworkDir.exists() }

		// Third-party frameworks - lazily walk artifactsDir at execution time using eachFile
		// to rewrite paths: any *.xcframework found anywhere under artifactsDir is placed at
		// ios/framework/<Name.xcframework>/...  (flattened, depth-agnostic)
		from(fileTree(artifactsDir) { include("**/*.xcframework/**") }) {
			includeEmptyDirs = false
			eachFile {
				val segs = relativePath.segments
				val xcfwIdx = segs.indexOfFirst { it.endsWith(".xcframework", ignoreCase = true) }
				if (xcfwIdx >= 0) {
					relativePath = RelativePath(true, "ios", "framework", *segs.drop(xcfwIdx).toTypedArray())
				} else {
					exclude()
				}
			}
		}

		// Plugin frameworks
		into("ios/plugins") {
			from(frameworkDir) {
				include("${pluginName}.release.xcframework/**")
				include("${pluginName}.debug.xcframework/**")
			}
		}

		// Addon output
		from("${rootDir}/../addon/build/output") {
			include("addons/${project.extra["pluginName"]}/**")
			include("ios/plugins/*.gdip")
		}

		inputs.dir(frameworkDir).optional(true)

		outputs.dir(destDir)
	}

	register("build") {
		description = "Builds both Android and iOS"

		dependsOn("buildAndroid")
		dependsOn("buildiOS")
	}

	register<Copy>("installToDemoAndroid") {
		description = "Copies the assembled Andoid plugin to demo application's addons directory"

		dependsOn("buildAndroidDebug")

		destinationDir = file("${project.extra["demoDir"]}")

		into(".") {
			from("${project.extra["pluginDir"]}/android")
		}
	}

	register<Copy>("installToDemoiOS") {
		description = "Copies the assembled iOS plugin to demo application's addons directory"

		dependsOn("copyiOSBuildArtifacts")

		destinationDir = file("${project.extra["demoDir"]}")

		into(".") {
			from("${project.extra["pluginDir"]}/ios")
		}
	}

	register<Copy>("installToDemo") {
		description = "Installs both the Android and iOS plugins to demo app"
		dependsOn("installToDemoAndroid", "installToDemoiOS")
	}

	register<Delete>("uninstallAndroid") {
		description = "Keep demo app's plugin directory and delete everything inside except for .uid and .import files"
		delete(fileTree("${project.extra["demoDir"]}/addons/${project.extra["pluginName"]}").apply {
			include("**/*")
			exclude("**/*.uid")
			exclude("**/*.import")
		})
	}

	register<Delete>("uninstalliOS") {
		description = "Keep .uid and .import files and delete the rest inside demo app's plugin directory. Delete plugin files inside demo ios directory."

		delete(fileTree("${project.extra["demoDir"]}/addons/${project.extra["pluginName"]}") {
			include("**/*")
			exclude("**/*.uid")
			exclude("**/*.import")
		})

		// iOS plugins cleanup (catches .gdip + .xcframework + .framework)
		val pluginName = project.extra["pluginName"] as String
		val pluginsDir = file("${project.extra["demoDir"]}/ios/plugins")

		// Delete every file/folder that belongs to this plugin
		delete(
			pluginsDir.listFiles()?.filter { it.name.startsWith("$pluginName.") }.orEmpty()
		)
	}

	register("uninstall") {
		description = "Cleans all build outputs"
		dependsOn("uninstallAndroid", "uninstalliOS")
	}

	register<Delete>("clean") {
		description = "Cleans all build outputs"
		dependsOn(":android:clean", ":addon:cleanOutput")

		delete("${project.extra["iosDir"] as String}/build")
	}

	register<Zip>("createAndroidArchive") {
		dependsOn("buildAndroidDebug", "buildAndroidRelease")

		val archiveName = project.extra["pluginArchiveAndroid"] as String
		val outputDir = project.extra["archiveDir"] as String
		val sourceDir = "${project.extra["pluginDir"] as String}/android"

		archiveFileName.set(archiveName)
		destinationDirectory.set(layout.projectDirectory.dir(outputDir))

		from(layout.projectDirectory.dir(sourceDir)) {
			includeEmptyDirs = false
		}

		doLast {
			println("Android zip archive created at: ${archiveFile.get().asFile.path}")
		}
	}

	register<Zip>("createiOSArchive") {
		dependsOn("buildiOS", "copyiOSBuildArtifacts")

		val archiveName = project.extra["pluginArchiveiOS"] as String
		val outputDir = project.extra["archiveDir"] as String
		val sourceDir = "${project.extra["pluginDir"] as String}/ios"

		archiveFileName.set(archiveName)
		destinationDirectory.set(layout.projectDirectory.dir(outputDir))

		duplicatesStrategy = DuplicatesStrategy.EXCLUDE

		from(layout.projectDirectory.dir(sourceDir)) {
			includeEmptyDirs = false
		}

		doLast {
			println("iOS zip archive created at: ${archiveFile.get().asFile.path}")
		}
	}

	register<Zip>("createMultiArchive") {
		dependsOn("buildAndroidDebug", "buildAndroidRelease", "buildiOS", "copyiOSBuildArtifacts")

		val archiveName = project.extra["pluginArchiveMulti"] as String
		val outputDir = project.extra["archiveDir"] as String
		val androidDir = "${project.extra["pluginDir"] as String}/android"
		val iosDir = "${project.extra["pluginDir"] as String}/ios"

		archiveFileName.set(archiveName)
		destinationDirectory.set(layout.projectDirectory.dir(outputDir))

		duplicatesStrategy = DuplicatesStrategy.EXCLUDE

		from(layout.projectDirectory.dir(androidDir)) {
			includeEmptyDirs = false
		}

		from(layout.projectDirectory.dir(iosDir)) {
			includeEmptyDirs = false
		}

		doLast {
			println("Multi zip archive created at: ${archiveFile.get().asFile.path}")
		}
	}

	register("createArchives") {
		description = "Creates both the Android and iOS zip archives"
		dependsOn("createAndroidArchive", "createiOSArchive", "createMultiArchive")
	}
}
