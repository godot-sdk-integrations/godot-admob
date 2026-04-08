//
// © 2026-present https://github.com/cengiz-pz
//

import org.gradle.process.ExecOperations
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

plugins {
    id("base-conventions")
    alias(libs.plugins.undercouch.download)
}

// -- Load config data classes --------------------------------------------------
//
// pluginDir, repositoryRootDir, archiveDir, demoDir, pluginArchiveiOS and all
// other shared extras are already set on project.extra by base-conventions.
// The typed data classes give cast-free, IDE-navigable access to all values.
// iosConfig replaces every manual ios.properties read that previously appeared
// inside doFirst / outputs.upToDateWhen blocks throughout this file.

val pluginConfig = loadPluginConfig()
val godotConfig = loadGodotConfig()
val iosConfig = loadIosConfig()

// -- Injected services interface -----------------------------------------------

interface Injected {
    @get:Inject
    val execOps: ExecOperations
}

val derivedDataDir = file("$projectDir/build/DerivedData")

// -- Helpers -------------------------------------------------------------------

fun buildTimestamp(): String = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))

/**
 * Registers one of the four iOS build variants. Runs xcodebuild archive directly
 * without delegating back to build_ios.sh.
 *
 * [iosConfig] is captured from the enclosing build script scope and used in
 * place of every manual ios.properties read that previously appeared inside
 * the doFirst block.
 *
 * @param name             task name, e.g. "buildiOSDebug"
 * @param description      human-readable description
 * @param sdk              xcodebuild -sdk value: "iphoneos" or "iphonesimulator"
 * @param archiveName      base name of the xcarchive, e.g. "ios_debug"
 * @param derivedDataName  subdirectory under DerivedData, e.g. "ios_debug"
 * @param isDebug          true -> adds GCC_PREPROCESSOR_DEFINITIONS with DEBUG_ENABLED=1
 */
fun TaskContainerScope.registerIosBuildTask(
    name: String,
    description: String,
    sdk: String,
    archiveName: String,
    derivedDataName: String,
    isDebug: Boolean,
) {
    val godotDir: String by project.gradle.extra

    val scheme = "${pluginConfig.pluginModuleName}_plugin"
    val workspace = file("$projectDir/plugin.xcodeproj/project.xcworkspace")
    val libDir = file("$projectDir/build/lib")
    val frameworkDir = file("$projectDir/build/framework")

    register<Exec>(name) {
        this.description = description
        group = "build"

        dependsOn(
            "validateSwiftVersion",
            "syncSwiftVersionToPbxproj",
            "validateGodotVersion",
            project(":addon").tasks.named("generateGDScript"),
            project(":addon").tasks.named("generateiOSConfig"),
            project(":addon").tasks.named("copyAssets"),
            "updateSPMDependencies",
            "resolveSPMDependencies",
            "downloadGodotHeaders",
        )

        inputs.files(project(":addon").tasks.named("generateGDScript").map { it.outputs.files })
        inputs.files(project(":addon").tasks.named("generateiOSConfig").map { it.outputs.files })
        inputs.files(project(":addon").tasks.named("copyAssets").map { it.outputs.files })
        inputs.dir("$projectDir/src")
        inputs.files(fileTree("$rootDir/config"))
        inputs.files(fileTree("$projectDir/config"))
        // Track swift_version as a build input - if it changes the task re-runs
        inputs.property("swiftVersion", iosConfig.swiftVersion)

        outputs.dir(libDir.resolve("$archiveName.xcarchive"))

        finalizedBy("copyiOSBuildArtifacts")

        doFirst {
            if (iosConfig.swiftVersion.isBlank()) {
                throw GradleException(
                    "ERROR: 'swift_version' is not configured in ios/config/ios.properties.\n" +
                        "Please add it before building, e.g.:\n    swift_version=5.9",
                )
            }

            frameworkDir.mkdirs()
            libDir.mkdirs()

            commandLine(
                buildList {
                    add("xcodebuild")
                    add("archive")
                    addAll(listOf("-workspace", workspace.absolutePath))
                    addAll(listOf("-scheme", scheme))
                    addAll(listOf("-archivePath", libDir.resolve("$archiveName.xcarchive").absolutePath))
                    addAll(listOf("-derivedDataPath", derivedDataDir.resolve(derivedDataName).absolutePath))
                    addAll(listOf("-sdk", sdk))
                    add("SKIP_INSTALL=NO")
                    if (isDebug) add("GCC_PREPROCESSOR_DEFINITIONS=\$(inherited) DEBUG_ENABLED=1")
                    add("GODOT_DIR=$godotDir")
                    add("SWIFT_VERSION=${iosConfig.swiftVersion}")
                },
            )
        }

        doLast {
            val archiveLib = libDir.resolve("$archiveName.xcarchive/Products/usr/local/lib")
            val builtLib = archiveLib.resolve("lib$scheme.a")
            val renamedLib = archiveLib.resolve("${pluginConfig.pluginName}.a")

            if (!builtLib.exists()) {
                throw GradleException("Expected build artifact not found: ${builtLib.absolutePath}")
            }
            if (!builtLib.renameTo(renamedLib)) {
                throw GradleException(
                    "Failed to rename ${builtLib.absolutePath} to ${renamedLib.absolutePath}",
                )
            }
            println("iOS build completed at: ${buildTimestamp()}")
        }
    }
}

/**
 * Registers an xcodebuild-test task that runs the iOS unit-test scheme on an
 * iOS Simulator.
 *
 * @param name         task name, e.g. "testiOS"
 * @param description  human-readable description
 * @param scheme       xcodebuild -scheme value, e.g. "${pluginModuleName}_plugin_tests"
 * @param destination  xcodebuild -destination value, e.g. "platform=iOS Simulator,name=iPhone 17"
 */
fun TaskContainerScope.registerIosTestTask(
    name: String,
    description: String,
    scheme: String,
    destination: String,
) {
    register<Exec>(name) {
        this.description = description
        group = "verification"

        dependsOn(
            "downloadGodotHeaders",
            "downloadGodotiOSLibrary",
            "validateGodotVersion",
            "validateSwiftVersion",
            "syncSwiftVersionToPbxproj",
            "resolveSPMDependencies",
            "bootiOSSimulator",
        )

        val godotDir: String by gradle.extra
        val workspace = file("$projectDir/plugin.xcodeproj/project.xcworkspace")
        val testResultsDir = file("$projectDir/build/TestResults")

        inputs.dir("$projectDir/src")
        inputs.dir("$projectDir/test")
        outputs.dir(testResultsDir)

        onlyIf("iOS test scheme exists") {
            workspace.exists()
        }

        doFirst {
            testResultsDir.mkdirs()

            // Try pulling from Gradle extra properties first (set by bootiOSSimulator), then fallback to env
            val simulatorUdid =
                if (project.extra.has("SIMULATOR_UDID")) {
                    project.extra["SIMULATOR_UDID"] as String
                } else {
                    System.getenv("SIMULATOR_UDID")?.takeIf { it.isNotBlank() }
                }

            val resolvedDestination =
                if (simulatorUdid != null) {
                    logger.lifecycle("testiOS: using SIMULATOR_UDID destination: id:{}", simulatorUdid)
                    "id=$simulatorUdid"
                } else {
                    logger.lifecycle("testiOS: local mode - using configured destination: {}", destination)
                    destination
                }

            commandLine(
                "xcodebuild",
                "test",
                "-workspace",
                workspace.absolutePath,
                "-scheme",
                scheme,
                "-destination",
                resolvedDestination,
                "-derivedDataPath",
                derivedDataDir.absolutePath,
                "-resultBundlePath",
                testResultsDir.resolve("$name.xcresult").absolutePath,
                "-enableCodeCoverage",
                "YES",
                "GODOT_DIR=$godotDir",
                "SWIFT_VERSION=${iosConfig.swiftVersion}",
            )

            // Set a timeout to prevent infinite hangs (30 minutes)
            timeout = java.time.Duration.ofMinutes(30)
        }

        finalizedBy("printTestSummaryiOS")
    }
}

/**
 * Registers a clang-format check or format task for ObjC/C++ sources.
 *
 * @param name        task name
 * @param description human-readable description
 * @param dryRun      true -> --dry-run --Werror, false -> -i (in-place)
 */
fun TaskContainerScope.registerObjCFormatTask(
    name: String,
    description: String,
    dryRun: Boolean,
) {
    val iosSrcDir = file("$projectDir/src")

    register<Exec>(name) {
        this.description = description
        this.group = if (dryRun) "verification" else "formatting"

        workingDir = iosSrcDir

        doFirst {
            val sourceFiles =
                fileTree(iosSrcDir) { include("**/*.mm", "**/*.m", "**/*.h") }
                    .files
                    .map { it.relativeTo(iosSrcDir).path }
                    .sorted()

            if (sourceFiles.isEmpty()) {
                throw GradleException("$name: no source files found under ${iosSrcDir.absolutePath}")
            }

            commandLine(
                buildList {
                    add("clang-format")
                    add("--style=file:../../.github/config/.clang-format")
                    if (dryRun) {
                        add("--dry-run")
                        add("--Werror")
                    } else {
                        add("-i")
                    }
                    addAll(sourceFiles)
                },
            )
        }
    }
}

/**
 * Registers a swiftlint check or fix task for Swift sources.
 *
 * @param name        task name
 * @param description human-readable description
 * @param fix         true -> --fix, false -> lint only
 */
fun TaskContainerScope.registerSwiftFormatTask(
    name: String,
    description: String,
    fix: Boolean,
) {
    val iosSrcDir = file("$projectDir/src")

    register<Exec>(name) {
        this.description = description
        this.group = if (fix) "formatting" else "verification"

        workingDir = iosSrcDir

        doFirst {
            val sourceFiles =
                fileTree(iosSrcDir) { include("**/*.swift") }
                    .files
                    .map { it.relativeTo(iosSrcDir).path }
                    .sorted()

            if (sourceFiles.isEmpty()) {
                throw GradleException("$name: no Swift source files found under ${iosSrcDir.absolutePath}")
            }

            commandLine(
                buildList {
                    add("swiftlint")
                    if (fix) add("--fix") else add("lint")
                    add("--config")
                    add("../../.github/config/.swiftlint.yml")
                    addAll(sourceFiles)
                },
            )
        }
    }
}

// -- Tasks ---------------------------------------------------------------------

tasks {
    val pluginDir: String by project.extra
    val repositoryRootDir: String by project.extra
    val archiveDir: String by project.extra
    val demoDir: String by project.extra
    val godotDir: String by gradle.extra

    register<Delete>("removeGodotDirectory") {
        description = "Removes the directory where Godot headers were downloaded"
        group = "setup"

        val godotDirectory = file(godotDir)

        doFirst {
            if (godotDirectory.exists()) {
                logger.lifecycle("Removing '{}' directory...", godotDirectory.absolutePath)
            } else {
                logger.warn("Warning: '{}' directory not found!", godotDirectory.absolutePath)
            }
        }

        delete(godotDirectory)
    }

    register<de.undercouch.gradle.tasks.download.Download>("downloadGodotHeaders") {
        description = "Downloads pre-built Godot headers into the configured directory"
        group = "setup"

        val godotDirectory = file(godotDir)
        val versionFile = godotDirectory.resolve("GODOT_VERSION")
        val filename = "godot-headers-${godotConfig.godotVersion}-${godotConfig.godotReleaseType}.zip"
        val releaseUrl =
            "https://github.com/godot-mobile-plugins/godot-headers/releases/download/" +
                "${godotConfig.godotVersion}-${godotConfig.godotReleaseType}/$filename"
        val archiveFile = file("$godotDir.zip")

        inputs.property("godotVersion", godotConfig.godotVersion)
        inputs.property("godotReleaseType", godotConfig.godotReleaseType)
        inputs.property("godotDir", godotDir)

        onlyIf {
            if (versionFile.exists() && versionFile.readText().trim() == godotConfig.godotVersion) {
                logger.info(
                    "Godot {} already present in {}. Skipping download.",
                    godotConfig.godotVersion,
                    godotDirectory.absolutePath,
                )
                return@onlyIf false
            }
            true
        }

        doFirst {
            if (godotDirectory.exists()) {
                if (!versionFile.exists()) {
                    throw GradleException(
                        "ERROR: Godot directory '${godotDirectory.absolutePath}' already exists " +
                            "but contains no GODOT_VERSION file.",
                    )
                }
                val existingVersion = versionFile.readText().trim()
                throw GradleException(
                    "ERROR: Godot directory '${godotDirectory.absolutePath}' already exists but " +
                        "contains version '$existingVersion', which does not match the " +
                        "configured version '${godotConfig.godotVersion}'. " +
                        "Remove the directory (or run 'removeGodotDirectory') before downloading again, " +
                        "or update 'godotVersion' in config/godot.properties.",
                )
            }
        }

        src(releaseUrl)
        dest(archiveFile)
        overwrite(false)

        doLast {
            godotDirectory.mkdirs()

            project.copy {
                from(project.zipTree(archiveFile))
                includeEmptyDirs = false
                into(godotDirectory)
            }

            archiveFile.delete()
            versionFile.writeText(godotConfig.godotVersion)

            println(
                "Godot headers ${godotConfig.godotVersion}-${godotConfig.godotReleaseType} successfully " +
                    "downloaded and extracted to ${godotDirectory.absolutePath}",
            )
        }
    }

    register<de.undercouch.gradle.tasks.download.Download>("downloadGodotiOSLibrary") {
        description = "Downloads the Godot iOS Simulator debug static library into the configured Godot directory"
        group = "setup"

        val godotDirectory = file(godotDir)
        val simulatorLib = godotDirectory.resolve("bin/libgodot.ios.template_debug.arm64.simulator.a")
        val archiveFile = godotDirectory.resolve(godotConfig.godotIosSimulatorLibZip)

        // Skip when the target library already exists
        onlyIf("Godot iOS Simulator library does not already exist") {
            if (simulatorLib.exists()) {
                logger.lifecycle(
                    "Godot iOS Simulator library already exists at ${simulatorLib.absolutePath}." +
                        " Skipping download.",
                )
                false
            } else {
                true
            }
        }

        inputs.property("godotVersion", godotConfig.godotVersion)
        inputs.property("godotReleaseType", godotConfig.godotReleaseType)
        inputs.property("godotDir", godotDir)

        src(godotConfig.godotIosSimulatorLibUrl)
        dest(archiveFile)
        overwrite(false)

        doLast {
            project.copy {
                from(project.zipTree(archiveFile))
                includeEmptyDirs = false
                into(godotDirectory)
                // Strip top-level wrapper directory so the result is always
                // $godotDir/bin/libgodot.ios.template_debug.arm64.simulator.a
                eachFile {
                    val segments = relativePath.segments
                    if (segments.size > 1) {
                        relativePath = RelativePath(true, *segments.drop(1).toTypedArray())
                    } else {
                        exclude()
                    }
                }
            }

            if (!simulatorLib.exists()) {
                throw GradleException(
                    "Extraction succeeded but expected library not found: ${simulatorLib.absolutePath}\n" +
                        "Check that the ZIP contains a bin/ directory with the .a file.",
                )
            }

            archiveFile.delete()

            println(
                "Godot iOS Simulator library ${godotConfig.godotVersion}-${godotConfig.godotReleaseType} " +
                    "successfully downloaded and extracted to ${simulatorLib.absolutePath}",
            )
        }
    }

    register("resetSPMDependencies") {
        description = "Removes SPM dependencies from the Xcode project and cleans up all SPM artifacts"
        group = "setup"

        inputs.files(fileTree("$projectDir/config"))

        val execOps = objects.newInstance<Injected>().execOps

        doLast {
            val spmConfigFile = file("$projectDir/config/spm_dependencies.json")
            val deps = readSpmDependencies(spmConfigFile)
            val xcodeproj = "$projectDir/plugin.xcodeproj"
            val scriptDir = file("$repositoryRootDir/script")

            if (deps.isEmpty()) {
                println("Warning: No dependencies found for plugin. Skipping SPM dependency removal.")
            } else {
                println("Removing SPM dependencies from project...")
                deps.forEach { dep ->
                    dep.products.forEach { product ->
                        execOps.exec {
                            commandLine(
                                "ruby",
                                "$scriptDir/spm_manager.rb",
                                "-d",
                                xcodeproj,
                                dep.url,
                                dep.version,
                                product,
                            )
                        }
                    }
                }

                println("Regenerating Package.resolved after dependency removal...")
                execOps.exec {
                    commandLine(
                        "xcodebuild",
                        "-resolvePackageDependencies",
                        "-project",
                        xcodeproj,
                        "-scheme",
                        "${pluginConfig.pluginModuleName}_plugin",
                        "-derivedDataPath",
                        "$projectDir/build/DerivedData",
                    )
                    isIgnoreExitValue = true
                }
            }

            val resolvedFile =
                file("$xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved")
            if (resolvedFile.exists()) {
                println("Removing ${resolvedFile.path} ...")
                resolvedFile.delete()
            }

            val sourcePackagesDir = file("$projectDir/build/DerivedData/SourcePackages")
            if (sourcePackagesDir.exists()) {
                println("Removing SPM cache directory ${sourcePackagesDir.path} ...")
                sourcePackagesDir.deleteRecursively()
            }
        }
    }

    register("updateSPMDependencies") {
        description = "Adds SPM dependencies from $projectDir/config/spm_dependencies.json into the Xcode project"
        group = "setup"

        inputs.files(fileTree("$projectDir/config"))
        outputs.file("$projectDir/plugin.xcodeproj/project.pbxproj")

        finalizedBy("resolveSPMDependencies")

        val execOps = objects.newInstance<Injected>().execOps

        doLast {
            val spmConfigFile = file("$projectDir/config/spm_dependencies.json")
            val deps = readSpmDependencies(spmConfigFile)

            if (deps.isEmpty()) {
                println("Warning: No dependencies found for plugin. Skipping SPM update.")
                return@doLast
            }

            val totalProducts = deps.sumOf { it.products.size }
            println("Found $totalProducts SPM ${if (totalProducts == 1) "dependency" else "dependencies"}:")
            deps.forEach { dep ->
                dep.products.forEach { println("\t• $it (${dep.url} @ ${dep.version})") }
            }
            println()

            val rubyAvailable =
                execOps
                    .exec {
                        commandLine("which", "ruby")
                        isIgnoreExitValue = true
                    }.exitValue == 0
            if (!rubyAvailable) {
                throw GradleException("Ruby is required to inject SPM dependencies but was not found on PATH.")
            }

            val gemAvailable =
                execOps
                    .exec {
                        commandLine("gem", "list", "-i", "^xcodeproj\$")
                        isIgnoreExitValue = true
                    }.exitValue == 0
            if (!gemAvailable) {
                println("Installing 'xcodeproj' Ruby gem...")
                execOps.exec { commandLine("gem", "install", "xcodeproj", "--user-install") }
            }

            val xcodeproj = "$projectDir/plugin.xcodeproj"
            val scriptDir = file("$repositoryRootDir/script")

            println("Updating Xcode project with SPM dependencies...")
            deps.forEach { dep ->
                dep.products.forEach { product ->
                    execOps.exec {
                        commandLine(
                            "ruby",
                            "$scriptDir/spm_manager.rb",
                            "-a",
                            xcodeproj,
                            dep.url,
                            dep.version,
                            product,
                        )
                    }
                }
            }
            println("SPM update completed.")
        }
    }

    register<Exec>("resolveSPMDependencies") {
        description = "Resolves SPM package dependencies via xcodebuild"
        group = "setup"

        mustRunAfter("updateSPMDependencies")

        val xcodeproj = "$projectDir/plugin.xcodeproj"

        inputs.file("$projectDir/config/spm_dependencies.json")
        inputs.files(fileTree(xcodeproj) { include("**/*.pbxproj", "**/project.pbxproj") })

        outputs.file("$xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved")
        outputs.dir(derivedDataDir.resolve("SourcePackages"))

        isIgnoreExitValue = true

        commandLine(
            "xcodebuild",
            "-resolvePackageDependencies",
            "-project",
            xcodeproj,
            "-scheme",
            "${pluginConfig.pluginModuleName}_plugin",
            "-derivedDataPath",
            derivedDataDir.absolutePath,
            "GODOT_DIR=$godotDir",
        )
    }

    register("validateSwiftVersion") {
        description = "Fails the build with a clear error if swift_version is missing from ios.properties"
        group = "verification"
        // Always re-run: this is a fast guard step whose purpose is to catch
        // misconfiguration before a slow Xcode build starts.
        outputs.upToDateWhen { false }

        // Track the value as an input so Gradle knows when it changes.
        inputs.property("swiftVersion", iosConfig.swiftVersion)

        doLast {
            if (iosConfig.swiftVersion.isBlank()) {
                throw GradleException(
                    "ERROR: 'swift_version' is not configured in ios/config/ios.properties.\n" +
                        "Please add it before building, e.g.:\n    swift_version=5.9",
                )
            }
        }
    }

    register("syncSwiftVersionToPbxproj") {
        description = "Syncs SWIFT_VERSION from ios.properties into plugin.xcodeproj/project.pbxproj"
        group = "setup"

        dependsOn("validateSwiftVersion")

        val pbxprojFile = file("$projectDir/plugin.xcodeproj/project.pbxproj")

        // Track swift_version as an input so the task re-runs when it changes.
        inputs.property("swiftVersion", iosConfig.swiftVersion)

        outputs.upToDateWhen {
            pbxprojFile.exists() &&
                pbxprojFile.readText().contains("SWIFT_VERSION = ${iosConfig.swiftVersion};")
        }

        doLast {
            if (iosConfig.swiftVersion.isBlank()) {
                throw GradleException("swift_version not set in ios/config/ios.properties")
            }

            val original = pbxprojFile.readText()
            val updated =
                original.replace(
                    Regex("SWIFT_VERSION = [0-9.]+;"),
                    "SWIFT_VERSION = ${iosConfig.swiftVersion};",
                )
            pbxprojFile.writeText(updated)

            logger.lifecycle("Synced SWIFT_VERSION = {} into {}", iosConfig.swiftVersion, pbxprojFile.absolutePath)
        }
    }

    register("validateGodotVersion") {
        description = "Validates that the Godot version in godotDir matches the configured godotVersion"
        group = "verification"

        dependsOn("downloadGodotHeaders")

        inputs.property("godotVersion", godotConfig.godotVersion)
        inputs.property("godotDirPath", godotDir)

        outputs.upToDateWhen {
            val vf = java.io.File("$godotDir/GODOT_VERSION")
            vf.exists() && vf.readText().trim() == godotConfig.godotVersion
        }

        doLast {
            val godotDirectory = java.io.File(godotDir)
            val versionFile = godotDirectory.resolve("GODOT_VERSION")
            if (!versionFile.exists()) {
                throw GradleException(
                    "GODOT_VERSION file not found in ${godotDirectory.absolutePath}. " +
                        "Run the 'downloadGodotHeaders' task first.",
                )
            }

            val downloadedVersion = versionFile.readText().trim()
            if (downloadedVersion != godotConfig.godotVersion) {
                throw GradleException(
                    "Godot version mismatch!\n" +
                        "  Expected (config/godot.properties): ${godotConfig.godotVersion}\n" +
                        "  Found    (${versionFile.absolutePath}): $downloadedVersion\n" +
                        "Ensure they match, or run 'removeGodotDirectory' then 'downloadGodotHeaders'.",
                )
            }

            logger.lifecycle("Godot version validation passed: {}", godotConfig.godotVersion)
        }
    }

    registerIosBuildTask(
        name = "buildiOSDebug",
        description = "Builds the iOS plugin (device, debug)",
        sdk = "iphoneos",
        archiveName = "ios_debug",
        derivedDataName = "ios_debug",
        isDebug = true,
    )
    registerIosBuildTask(
        name = "buildiOSRelease",
        description = "Builds the iOS plugin (device, release)",
        sdk = "iphoneos",
        archiveName = "ios_release",
        derivedDataName = "ios_release",
        isDebug = false,
    )
    registerIosBuildTask(
        name = "buildiOSDebugSimulator",
        description = "Builds the iOS plugin (simulator, debug)",
        sdk = "iphonesimulator",
        archiveName = "sim_debug",
        derivedDataName = "ios_simulator_debug",
        isDebug = true,
    )
    registerIosBuildTask(
        name = "buildiOSReleaseSimulator",
        description = "Builds the iOS plugin (simulator, release)",
        sdk = "iphonesimulator",
        archiveName = "sim_release",
        derivedDataName = "ios_simulator_release",
        isDebug = false,
    )

    register("buildiOS") {
        description = "Builds both debug and release"
        group = "build"
        dependsOn("buildiOSDebug", "buildiOSRelease")
    }

    register<Sync>("copyiOSBuildArtifacts") {
        description = "Copies iOS build artifacts (plugin xcframeworks and addon files) to the plugin directory"
        group = "build"

        dependsOn(
            project(":addon").tasks.named("copyAssets"),
            project(":addon").tasks.named("generateGDScript"),
            project(":addon").tasks.named("generateiOSConfig"),
        )
        mustRunAfter("buildiOSDebug", "buildiOSDebugSimulator", "buildiOSRelease", "buildiOSReleaseSimulator")

        val buildDir = file(projectDir).resolve("build")
        val frameworkDir = buildDir.resolve("framework")
        val libDir = buildDir.resolve("lib")
        val destDir = file(pluginDir).resolve("ios")

        destinationDir = destDir

        doFirst {
            destDir
                .resolve("ios/framework")
                .takeIf { it.exists() }
                ?.walkBottomUp()
                ?.forEach { it.setWritable(true) }

            val execOps = objects.newInstance<Injected>().execOps
            frameworkDir.mkdirs()

            fun createXcframework(
                variantName: String,
                archiveNames: List<String>,
            ) {
                val availableLibs =
                    archiveNames.mapNotNull { archiveName ->
                        libDir
                            .resolve("$archiveName/Products/usr/local/lib/${pluginConfig.pluginName}.a")
                            .takeIf { it.exists() }
                    }
                if (availableLibs.isEmpty()) {
                    println("Skipping ${pluginConfig.pluginName}.$variantName.xcframework: no build artifacts found.")
                    return
                }
                val output = frameworkDir.resolve("${pluginConfig.pluginName}.$variantName.xcframework")
                if (output.exists()) output.deleteRecursively()

                println(
                    "Creating ${pluginConfig.pluginName}.$variantName.xcframework from " +
                        "${availableLibs.size} slice(s): " +
                        "${availableLibs.map { it.parentFile.parentFile.parentFile.name }}",
                )
                execOps.exec {
                    commandLine(
                        buildList {
                            add("xcodebuild")
                            add("-create-xcframework")
                            availableLibs.forEach { lib -> addAll(listOf("-library", lib.absolutePath)) }
                            addAll(listOf("-output", output.absolutePath))
                        },
                    )
                }
            }

            createXcframework("debug", listOf("ios_debug.xcarchive", "sim_debug.xcarchive"))
            createXcframework("release", listOf("ios_release.xcarchive", "sim_release.xcarchive"))
        }

        duplicatesStrategy = DuplicatesStrategy.EXCLUDE

        // SPM dependencies are resolved by Xcode at Godot export time via the
        // project's Package.resolved. Only the plugin's own xcframeworks are copied here.
        inputs.dir(frameworkDir).optional(true)
        outputs.dir(destDir)

        into("ios/plugins") {
            from(frameworkDir) {
                include("${pluginConfig.pluginName}.debug.xcframework/**")
                include("${pluginConfig.pluginName}.release.xcframework/**")
            }
        }

        from("$repositoryRootDir/addon/build/output") {
            include("addons/${pluginConfig.pluginName}/**")
            include("addons/GMPShared/**")
            include("ios/plugins/*.gdip")
        }
    }

    register<Copy>("installToDemoiOS") {
        description = "Copies the assembled iOS plugin to demo application's addons directory"
        group = "install"

        dependsOn("buildiOSDebug", "copyiOSBuildArtifacts")

        inputs.files(project.tasks.named("copyiOSBuildArtifacts").map { it.outputs.files })

        destinationDir = file(demoDir)
        duplicatesStrategy = DuplicatesStrategy.WARN

        doFirst {
            file(demoDir)
                .resolve("ios/framework")
                .takeIf { it.exists() }
                ?.walkBottomUp()
                ?.forEach { it.setWritable(true) }
        }

        into(".") { from("$pluginDir/ios") }

        outputs.dir(destinationDir)
    }

    register<Delete>("uninstalliOS") {
        description = "Removes plugin files from demo app (preserves .uid and .import files)"
        group = "uninstall"

        delete(
            fileTree("$demoDir/addons/${pluginConfig.pluginName}") {
                include("**/*")
                exclude("**/*.uid", "**/*.import")
            },
        )

        delete(
            file("$demoDir/ios/plugins")
                .listFiles()
                ?.filter { it.name.startsWith("${pluginConfig.pluginName}.") }
                .orEmpty(),
        )
    }

    register<Delete>("cleaniOSBuild") {
        group = "clean"
        description = "Cleans iOS build outputs"

        val iosBuildDir = provider { project.file("$projectDir/build") }

        doFirst {
            val dir = iosBuildDir.get()
            if (dir.exists()) {
                logger.lifecycle("Removing iOS build directory: ${dir.absolutePath}")
            } else {
                logger.lifecycle("iOS build directory did not exist (already clean): ${dir.absolutePath}")
            }
        }

        delete(iosBuildDir)
    }

    register<Delete>("cleaniOS") {
        group = "clean"
        description = "Cleans iOS build outputs and test results"

        dependsOn(
            "cleaniOSBuild",
            "cleaniOSTest",
        )
    }

    register<Zip>("createiOSArchive") {
        dependsOn("buildiOS", "copyiOSBuildArtifacts")

        group = "archive"
        archiveFileName.set("${pluginConfig.pluginName}-iOS-v${pluginConfig.pluginVersion}.zip")
        destinationDirectory.set(layout.projectDirectory.dir(archiveDir))
        duplicatesStrategy = DuplicatesStrategy.EXCLUDE

        into("res") {
            from(layout.projectDirectory.dir("$pluginDir/ios")) {
                includeEmptyDirs = false
                // SPM dependency xcframeworks are resolved by Xcode at export time
                // and must not be included in the distributed plugin archive.
                exclude("ios/framework/**")
            }
        }

        doLast { println("iOS zip archive created at: ${archiveFile.get().asFile.path}") }
    }

    register("bootiOSSimulator") {
        description = "Boots the configured iOS Simulator (headless) and waits for SpringBoard"
        group = "setup"

        val execOps = objects.newInstance<Injected>().execOps

        doLast {
            val destName = iosConfig.testDestinationName

            val listOutput = java.io.ByteArrayOutputStream()
            execOps.exec {
                commandLine("xcrun", "simctl", "list", "devices", "available", "-j")
                standardOutput = listOutput
            }

            // Parse xcrun JSON output
            val jsonSlurper = groovy.json.JsonSlurper()

            @Suppress("UNCHECKED_CAST")
            val parsed = jsonSlurper.parseText(listOutput.toString("UTF-8")) as Map<String, Any>

            @Suppress("UNCHECKED_CAST")
            val devices = parsed["devices"] as Map<String, List<Map<String, Any>>>

            var udid: String? = null
            for ((_, devs) in devices) {
                for (dev in devs) {
                    if (dev["name"] == destName && dev["isAvailable"] == true) {
                        udid = dev["udid"] as String
                        break
                    }
                }
                if (udid != null) break
            }

            if (udid.isNullOrBlank()) {
                execOps.exec { commandLine("xcrun", "simctl", "list", "devices", "available") }
                throw GradleException("ERROR: Simulator '$destName' not found.")
            }

            logger.lifecycle("Booting simulator UDID: {}", udid)

            // Headless simulator boot
            execOps.exec {
                commandLine("xcrun", "simctl", "boot", udid)
                isIgnoreExitValue = true // already booted is OK
            }

            // Ensure boot is complete (with 2-minute timeout)
            val bashTimeoutScript =
                """
                xcrun simctl bootstatus $udid -b &
                BOOT_PID=$!;
                (sleep 120 && kill ${'$'}BOOT_PID 2>/dev/null) &
                wait ${'$'}BOOT_PID
                """.trimIndent().replace("\n", " ")

            execOps.exec {
                commandLine("sh", "-c", bashTimeoutScript)
                isIgnoreExitValue = true // Don't fail if timeout occurs
            }

            logger.lifecycle("SpringBoard ready. UUD: {}", udid)

            // Save UDID for the testiOS task to consume
            project.extra.set("SIMULATOR_UDID", udid)
        }
    }

    val pluginModuleTestScheme = "${pluginConfig.pluginModuleName}_plugin_tests"
    val testDestination =
        "platform=${iosConfig.testPlatform},name=${iosConfig.testDestinationName},OS=${iosConfig.testOs}"

    registerIosTestTask(
        name = "testiOS",
        description = "Runs iOS unit tests on iOS Device or Simulator",
        scheme = pluginModuleTestScheme,
        destination = testDestination,
    )

    register("printTestSummaryiOS") {
        description = "Prints a clean test summary (tests per suite + coverage) from the xcresult bundle"
        group = "verification"

        val testResultsDir = file("$projectDir/build/TestResults")
        val resultBundle = testResultsDir.resolve("testiOS.xcresult")
        val execOps = objects.newInstance<Injected>().execOps

        doLast {
            if (!resultBundle.exists()) {
                println("❌ No xcresult bundle found - testiOS may have been skipped.")
                return@doLast
            }

            val bundlePath = resultBundle.absolutePath
            var reportScript =
                """
                BUNDLE="${'$'}(echo '$bundlePath')"

                echo "📋 iOS Test Summary"
                echo "═══════════════════════════════════════════════════════════════"

                JSON=${'$'}(xcrun xcresulttool get test-results summary \
                    --path "${'$'}BUNDLE" --format json 2>/dev/null || echo '{}')

                echo "${'$'}JSON" | jq -r '
                    (.passedTests + .failedTests + (.skippedTests // 0)) as ${'$'}total |
                    (.passedTests * 100 / (if ${'$'}total > 0 then ${'$'}total else 1 end) | round) as ${'$'}rate |

                    "Total Tests : \( ${'$'}total )",
                    "Passed      : \(.passedTests)",
                    "Failed      : \(.failedTests)",
                    "Skipped     : \(.skippedTests // 0)",
                    "Pass Rate   : \(if ${'$'}total > 0 then (${'$'}rate | tostring) + "%" else "N/A" end)",
                    "",
                    "Environment : \(.environmentDescription // "Unknown")",
                    "Result      : \(.result // "Unknown")",
                    "",
                    "Configurations:",
                    "───────────────",
                    (.devicesAndConfigurations[]? |
                        "  • \(.device.deviceName) (\(.device.osVersion))" +
                        " | Passed: \(.passedTests) | Failed: \(.failedTests)"
                    )
                ' 2>/dev/null || echo "⚠️  Could not parse test summary JSON"

                echo ""
                echo "📦 Test Suites"
                echo "───────────────"
                xcrun xcresulttool get test-results tests \
                    --path "${'$'}BUNDLE" --format json 2>/dev/null \
                | jq -r '
                    .testNodes[]? | .children[]? |
                    "  \(.name): passed=\(.result)"
                ' 2>/dev/null || echo "  (suite breakdown unavailable)"

                echo ""
                echo "🧪 Code Coverage"
                echo "───────────────"
                xcrun xccov view --report --json "${'$'}BUNDLE" 2>/dev/null \
                | jq -r '
                    (.targets // [])[] |
                    "  \(.name): \(.lineCoverage * 100 | round)% line coverage " +
                    " (\(.coveredLines)/\(.executableLines) lines)"
                ' 2>/dev/null || echo "  (coverage data unavailable - was -enableCodeCoverage YES set?)"
                """.trimIndent()

            execOps.exec {
                commandLine(
                    "sh",
                    "-c",
                    reportScript,
                )
                isIgnoreExitValue = true
            }
        }
    }

    register<Delete>("cleaniOSTest") {
        description = "Cleans iOS test result bundles"
        group = "clean"
        delete(file("$projectDir/build/TestResults"))
    }

    registerObjCFormatTask(
        "checkObjCFormat",
        "Checks clang-format compliance of iOS source files (dry-run)",
        dryRun = true,
    )
    registerObjCFormatTask(
        "formatObjCSource",
        "Formats iOS ObjC/C++ source files in-place using clang-format",
        dryRun = false,
    )

    registerSwiftFormatTask(
        "checkSwiftFormat",
        "Checks swiftlint compliance of Swift source files (lint only)",
        fix = false,
    )
    registerSwiftFormatTask(
        "formatSwiftSource",
        "Formats Swift source files in-place using swiftlint --fix",
        fix = true,
    )
}
