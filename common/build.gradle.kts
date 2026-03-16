//
// © 2026-present https://github.com/cengiz-pz
//

plugins {
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.undercouch.download) apply false
    alias(libs.plugins.openrewrite) apply false
    alias(libs.plugins.node) apply false
    alias(libs.plugins.kotlin.serialization) apply false
//    alias(libs.plugins.spotless) apply false
}

allprojects {
    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:unchecked")
        options.compilerArgs.add("-Xlint:deprecation")
    }
}

// Load configuration from project root
apply(from = "$rootDir/config/common.gradle.kts")

tasks {
    val pluginDir: String by project.extra
    val repositoryRootDir: String by project.extra
    val archiveDir: String by project.extra

    register("build") {
        description = "Builds both Android and iOS"

        dependsOn(
            project(":android").tasks.named("buildAndroid"),
            project(":ios").tasks.named("buildiOS"),
        )
    }

    register<Copy>("installToDemo") {
        description = "Installs both the Android and iOS plugins to demo app"

        dependsOn(
            project(":android").tasks.named("installToDemoAndroid"),
            project(":ios").tasks.named("installToDemoiOS"),
        )
    }

    register("uninstall") {
        description = "Cleans all build outputs"

        dependsOn(
            project(":android").tasks.named("uninstallAndroid"),
            project(":ios").tasks.named("uninstalliOS"),
        )
    }

    register<Delete>("clean") {
        description = "Cleans all build outputs"

        dependsOn(
            project(":addon").tasks.named("cleanOutput"),
            project(":android").tasks.named("clean"),
            project(":ios").tasks.named("cleaniOSBuild"),
        )
    }

    register<Zip>("createMultiArchive") {
        dependsOn(
            project(":android").tasks.named("buildAndroidDebug"),
            project(":android").tasks.named("buildAndroidRelease"),
            project(":ios").tasks.named("buildiOS"),
            project(":ios").tasks.named("copyiOSBuildArtifacts"),
        )

        val archiveName = project.extra["pluginArchiveMulti"] as String
        val androidDir = "$pluginDir/android"
        val iosDir = "$pluginDir/ios"

        archiveFileName.set(archiveName)
        destinationDirectory.set(layout.projectDirectory.dir(archiveDir))

        duplicatesStrategy = DuplicatesStrategy.EXCLUDE

        into("res") {
            from(layout.projectDirectory.dir(androidDir)) {
                includeEmptyDirs = false
            }

            from(layout.projectDirectory.dir(iosDir)) {
                includeEmptyDirs = false
            }
        }

        doLast {
            println("Multi zip archive created at: ${archiveFile.get().asFile.path}")
        }
    }

    register("createArchives") {
        description = "Creates both the Android and iOS zip archives"
        dependsOn(
            project(":android").tasks.named("createAndroidArchive"),
            project(":ios").tasks.named("createiOSArchive"),
            "createMultiArchive",
        )
    }

    register<Exec>("checkKtsFormat") {
        description = "Checks ktlint compliance of Gradle Kotlin DSL files (dry-run, no changes written)"
        group = "formatting"

        workingDir = file(repositoryRootDir)

        doFirst {
            val sourceFiles =
                listOf("addon", "android", "common", "ios")
                    .flatMap { dir ->
                        fileTree("$repositoryRootDir/$dir") {
                            include("*.gradle.kts")
                        }.files
                    }.map { it.relativeTo(file(repositoryRootDir)).path }
                    .sorted()

            if (sourceFiles.isEmpty()) {
                throw GradleException(
                    "checkKtsFormat: no *.gradle.kts files found under addon/, android/, or common/, " +
                        "or ios/",
                )
            }

            commandLine(
                buildList {
                    add("ktlint")
                    addAll(sourceFiles)
                },
            )
        }
    }

    register<Exec>("formatKtsSource") {
        description = "Formats Gradle Kotlin DSL files in-place using ktlint --format"
        group = "formatting"

        workingDir = file(repositoryRootDir)

        doFirst {
            val sourceFiles =
                listOf("addon", "android", "common", "ios")
                    .flatMap { dir ->
                        fileTree("$repositoryRootDir/$dir") {
                            include("*.gradle.kts")
                        }.files
                    }.map { it.relativeTo(file(repositoryRootDir)).path }
                    .sorted()

            if (sourceFiles.isEmpty()) {
                throw GradleException(
                    "formatKtsSource: no *.gradle.kts files found under addon/, android/, common/, or" +
                        " ios/",
                )
            }

            commandLine(
                buildList {
                    add("ktlint")
                    add("--format")
                    addAll(sourceFiles)
                },
            )
        }
    }

    register("checkFormat") {
        description = "Validates format in all source code"

        // Removed "spotlessCheck"
        dependsOn(
            project(":addon").tasks.named("checkGdscriptFormat"),
            project(":android").tasks.named("rewriteDryRun"),
            project(":android").tasks.named("checkXmlFormat"),
            project(":ios").tasks.named("checkIosFormat"),
            "checkKtsFormat",
        )
    }

    register("applyFormat") {
        description = "Formats all source code"

        // Removed "spotlessApply"
        dependsOn(
            project(":addon").tasks.named("formatGdscriptSource"),
            project(":android").tasks.named("rewriteRun"),
            project(":android").tasks.named("formatXml"),
            project(":ios").tasks.named("formatIosSource"),
            "formatKtsSource",
        )
    }
}
