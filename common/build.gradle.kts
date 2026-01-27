//
// © 2024-present https://github.com/cengiz-pz
//

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
	register<Copy>("buildDebug") {
		description = "Copies the generated GDScript and debug AAR binary to the plugin directory"
		dependsOn(":addon:generateGDScript")
        dependsOn(":addon:copyAssets")
		dependsOn(":android:assembleDebug")

        destinationDir = file("${project.extra["pluginDir"]}")

		into(".") {
			from("${rootDir}/../addon/build/output/")
		}

		into("${project.extra["pluginName"]}/bin/debug") {
			from("${rootDir}/../android/build/outputs/aar")
			include("${project.extra["pluginName"]}-debug.aar")
		}
	}

	register<Copy>("buildRelease") {
		description = "Copies the generated GDScript and release AAR binary to the plugin directory"
		dependsOn(":addon:generateGDScript")
        dependsOn(":addon:copyAssets")
		dependsOn(":android:assembleRelease")

        destinationDir = file("${project.extra["pluginDir"]}")

		into(".") {
			from("${rootDir}/../addon/build/output/")
		}

		into("${project.extra["pluginName"]}/bin/release") {
			from("${rootDir}/../android/build/outputs/aar")
			include("${project.extra["pluginName"]}-release.aar")
		}
	}

	register("build") {
		description = "Builds both debug and release"
		dependsOn("buildDebug")
		dependsOn("buildRelease")
	}

	register<Copy>("installToDemo") {
		description = "Copies the assembled plugin to demo application's addons directory"
		dependsOn("buildDebug")

        destinationDir = file("${project.extra["demoAddonsDir"]}")

		into(".") {
			from("${project.extra["pluginDir"]}")
		}
	}

	register<Delete>("cleanDemoAddons") {
		// Keep the directory itself and delete everything inside except for .uid and .import files
		delete(fileTree("${project.extra["demoAddonsDir"]}/${project.extra["pluginName"]}").apply {
			include("**/*")
			exclude("**/*.uid")
			exclude("**/*.import")
		})
	}

	register("clean") {
		description = "Cleans all build outputs"
		dependsOn("cleanDemoAddons")
		dependsOn(":android:clean")
		dependsOn(":addon:cleanOutput")
	}

	register<Zip>("createArchive") {
		dependsOn("buildDebug")
		dependsOn("buildRelease")

		archiveFileName.set(project.extra["pluginArchive"] as String)
		destinationDirectory.set(file("${project.extra["archiveDir"] as String}"))

		from("${project.extra["pluginDir"]}/${project.extra["pluginName"]}") {
			includeEmptyDirs = false

			eachFile {
				path = "addons/${project.extra["pluginName"]}/$path"
			}
		}

		doLast {
			println("Zip archive created at: ${archiveFile.get().asFile.path}")
		}
	}
}