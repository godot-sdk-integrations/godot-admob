//
// © 2026-present https://github.com/cengiz-pz
//

plugins {
    id("base-conventions")
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.undercouch.download) apply false
    alias(libs.plugins.openrewrite) apply false
    alias(libs.plugins.node) apply false
    alias(libs.plugins.kotlin.serialization) apply false
}

// ── Load config data class ────────────────────────────────────────────────────
//
// pluginDir, repositoryRootDir, archiveDir, and all other shared extras are
// already set on project.extra by base-conventions.  pluginConfig is loaded
// here for typed member access in createMultiArchive and ktsSourceFiles().

val pluginConfig = loadPluginConfig()

allprojects {
    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:unchecked")
        options.compilerArgs.add("-Xlint:deprecation")
    }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/** Returns all *.gradle.kts files under addon/, android/, common/, and ios/. */
fun ktsSourceFiles(): List<String> {
    val repositoryRootDir: String by project.extra
    return listOf("addon", "android", "common", "ios")
        .flatMap { dir ->
            fileTree("$repositoryRootDir/$dir") { include("*.gradle.kts") }.files
        }.map { it.relativeTo(file(repositoryRootDir)).path }
        .sorted()
}

// ── Tasks ─────────────────────────────────────────────────────────────────────

tasks {
    val pluginDir: String by project.extra
    val repositoryRootDir: String by project.extra
    val archiveDir: String by project.extra

    register("build") {
        description = "Builds both Android and iOS"
        group = "build"
        dependsOn(
            project(":android").tasks.named("buildAndroid"),
            project(":ios").tasks.named("buildiOS"),
        )
    }

    register("installToDemo") {
        description = "Installs both the Android and iOS plugins to demo app"
        group = "install"
        dependsOn(
            project(":android").tasks.named("installToDemoAndroid"),
            project(":ios").tasks.named("installToDemoiOS"),
        )
    }

    register("uninstall") {
        description = "Uninstalls all plugins from demo app"
        group = "uninstall"
        dependsOn(
            project(":android").tasks.named("uninstallAndroid"),
            project(":ios").tasks.named("uninstalliOS"),
        )
    }

    register("clean") {
        description = "Cleans all build outputs"
        group = "clean"
        dependsOn(
            project(":addon").tasks.named("cleanOutput"),
            project(":android").tasks.named("clean"),
            project(":ios").tasks.named("cleaniOSBuild"),
        )
        delete(layout.projectDirectory.dir(archiveDir))
    }

    register<Zip>("createMultiArchive") {
        dependsOn(
            project(":android").tasks.named("buildAndroidDebug"),
            project(":android").tasks.named("buildAndroidRelease"),
            project(":ios").tasks.named("buildiOS"),
            project(":ios").tasks.named("copyiOSBuildArtifacts"),
        )

        group = "archive"
        archiveFileName.set("${pluginConfig.pluginName}-Multi-v${pluginConfig.pluginVersion}.zip")
        destinationDirectory.set(layout.projectDirectory.dir(archiveDir))
        duplicatesStrategy = DuplicatesStrategy.EXCLUDE

        into("res") {
            from(layout.projectDirectory.dir("$pluginDir/android")) { includeEmptyDirs = false }
            from(layout.projectDirectory.dir("$pluginDir/ios")) {
                includeEmptyDirs = false
                // SPM dependency xcframeworks are resolved by Xcode at export time
                // and must not be included in the distributed plugin archive.
                exclude("ios/framework/**")
            }
        }

        doLast { println("Multi zip archive created at: ${archiveFile.get().asFile.path}") }
    }

    register("createArchives") {
        description = "Creates both the Android and iOS zip archives"
        group = "archive"
        dependsOn(
            project(":android").tasks.named("createAndroidArchive"),
            project(":ios").tasks.named("createiOSArchive"),
            "createMultiArchive",
        )
    }

    register<Exec>("checkEditorConfig") {
        description = "Checks editorconfig compliance of all source files"
        group = "verification"

        workingDir = file(repositoryRootDir)

        val namePatterns =
            listOf(
                "*.gradle.kts",
                "*.properties",
                "*.json",
                "*.gd",
                "*.java",
                "*.kt",
                "*.h",
                "*.m",
                "*.mm",
                "*.swift",
                "*.sh",
                "*.rb",
            ).joinToString(" -o ") { "-name \"$it\"" }

        val excludePatterns =
            listOf("node_modules", ".git", "build", ".gradle", ".idea")
                .joinToString(" ") { "-not -path \"*/$it/*\"" }

        commandLine(
            "sh",
            "-c",
            """
            files=$(find . \( $namePatterns \) $excludePatterns \
                -not -path "./demo/addons/*" \
                -not -name "package.json" \
                -not -name "package-lock.json")
            if [ -z "${'$'}files" ]; then
                echo "checkEditorConfig: no source files found" >&2
                exit 1
            fi
            echo "${'$'}files" | tr '\n' '\0' | xargs -0 editorconfig-checker
            """.trimIndent(),
        )
    }

    register<Exec>("checkKtsFormat") {
        description = "Checks ktlint compliance of Gradle Kotlin DSL files (dry-run)"
        group = "verification"

        workingDir = file(repositoryRootDir)

        doFirst {
            val sourceFiles = ktsSourceFiles()
            if (sourceFiles.isEmpty()) {
                throw GradleException(
                    "checkKtsFormat: no *.gradle.kts files found under addon/, android/, common/, or ios/",
                )
            }
            commandLine(listOf("ktlint") + sourceFiles)
        }
    }

    register<Exec>("formatKtsSource") {
        description = "Formats Gradle Kotlin DSL files in-place using ktlint --format"
        group = "formatting"

        workingDir = file(repositoryRootDir)

        doFirst {
            val sourceFiles = ktsSourceFiles()
            if (sourceFiles.isEmpty()) {
                throw GradleException(
                    "formatKtsSource: no *.gradle.kts files found under addon/, android/, common/, or ios/",
                )
            }
            commandLine(listOf("ktlint", "--format") + sourceFiles)
        }
    }

    register<Exec>("checkBashScriptFormat") {
        description = "Checks ShellCheck compliance of all shell scripts under script/"
        group = "verification"

        workingDir = file(repositoryRootDir)

        doFirst {
            val shellcheckAvailable =
                project
                    .exec {
                        commandLine("which", "shellcheck")
                        isIgnoreExitValue = true
                    }.exitValue == 0
            if (!shellcheckAvailable) {
                throw GradleException(
                    "shellcheck is not installed or not on PATH.\n" +
                        "See https://github.com/koalaman/shellcheck for installation instructions.",
                )
            }

            val sourceFiles =
                fileTree("$repositoryRootDir/script") { include("**/*.sh") }
                    .files
                    .map { it.absolutePath }
                    .sorted()
            if (sourceFiles.isEmpty()) {
                throw GradleException("checkBashScriptFormat: no *.sh files found under script/")
            }

            commandLine(listOf("shellcheck") + sourceFiles)
        }
    }

    register<Exec>("applyBashScriptFormat") {
        description = "Applies ShellCheck suggested fixes to shell scripts under script/ via git apply"
        group = "formatting"

        workingDir = file(repositoryRootDir)

        doFirst {
            val shellcheckAvailable =
                project
                    .exec {
                        commandLine("which", "shellcheck")
                        isIgnoreExitValue = true
                    }.exitValue == 0
            if (!shellcheckAvailable) {
                throw GradleException(
                    "shellcheck is not installed or not on PATH.\n" +
                        "See https://github.com/koalaman/shellcheck for installation instructions.",
                )
            }

            commandLine(
                "sh",
                "-c",
                "find script -name '*.sh' -print0 | xargs -0 shellcheck --format=diff | git apply --allow-empty",
            )
        }
    }

    register("checkFormat") {
        description = "Validates format in all source code"
        group = "verification"
        dependsOn(
            project(":addon").tasks.named("checkGdscriptFormat"),
            project(":android").tasks.named("checkJavaFormat"),
            project(":android").tasks.named("checkXmlFormat"),
            project(":ios").tasks.named("checkObjCFormat"),
            project(":ios").tasks.named("checkSwiftFormat"),
            "checkKtsFormat",
            "checkBashScriptFormat",
            "checkEditorConfig",
        )
    }

    register("applyFormat") {
        description = "Formats all source code"
        group = "formatting"
        dependsOn(
            project(":addon").tasks.named("formatGdscriptSource"),
            project(":android").tasks.named("rewriteRun"),
            project(":android").tasks.named("formatXml"),
            project(":ios").tasks.named("formatObjCSource"),
            project(":ios").tasks.named("formatSwiftSource"),
            "formatKtsSource",
            "applyBashScriptFormat",
        )
    }
}
