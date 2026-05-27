//
// © 2026-present https://github.com/cengiz-pz
//

import java.io.File
import java.util.Properties

/**
 * Immutable value object holding every setting from `common/config/godot.properties`.
 *
 * Obtain an instance via [Project.loadGodotConfig] (defined in `ProjectExtensions.kt`),
 * which is available in any project build script that applies `id("base-conventions")`:
 *
 * ```kotlin
 * plugins { id("base-conventions") }
 *
 * val godotConfig = loadGodotConfig()
 * println(godotConfig.godotVersion)    // "4.3"
 * println(godotConfig.godotAarFile)    // "godot-lib-4.3.stable.aar"
 * ```
 *
 * Derived properties ([godotAarUrl], [godotAarFile]) are computed from the raw version
 * fields and are never stored in the `.properties` file.
 */
data class GodotConfig(
    /** Godot engine version, e.g. `4.3`. */
    val godotVersion: String,
    /** Release qualifier appended to the version, e.g. `stable`. */
    val godotReleaseType: String,
) {
    /**
     * Full download URL for the Godot Android template AAR on GitHub Releases.
     *
     * Pattern:
     * ```
     * https://github.com/godotengine/godot-builds/releases/download/<version>-<releaseType>/
     *     godot-lib.<version>.<releaseType>.template_release.aar
     * ```
     */
    val godotAarUrl: String
        get() =
            "https://github.com/godotengine/godot-builds/releases/download/" +
                "$godotVersion-$godotReleaseType/" +
                "godot-lib.$godotVersion.$godotReleaseType.template_release.aar"

    /** Local filename for the cached AAR in the flat-dir repository, e.g. `godot-lib-4.3.stable.aar`. */
    val godotAarFile: String
        get() = "godot-lib-$godotVersion.$godotReleaseType.aar"

    /**
     * ZIP archive name for the iOS Simulator debug library,
     * e.g. `godot-ios-simulator-debug-4.6-stable.zip`.
     */
    val godotIosSimulatorLibZip: String
        get() = "godot-ios-simulator-debug-$godotVersion-$godotReleaseType.zip"

    /**
     * Full download URL for the iOS Simulator debug static library on GitHub Releases.
     *
     * Pattern:
     * ```
     * https://github.com/godot-mobile-plugins/godot-ios-builds/releases/download/<version>-<releaseType>/
     *     godot-ios-simulator-debug-<version>-<releaseType>.zip
     * ```
     *
     * Example:
     * ```
     * https://github.com/godot-mobile-plugins/godot-ios-builds/releases/download/4.6-stable/
     *     godot-ios-simulator-debug-4.6-stable.zip
     * ```
     */
    val godotIosSimulatorLibUrl: String
        get() =
            "https://github.com/godot-mobile-plugins/godot-ios-builds/releases/download/" +
                "$godotVersion-$godotReleaseType/$godotIosSimulatorLibZip"

    companion object {
        /**
         * Loads a [GodotConfig] from `config/godot.properties` inside [gradleRootDir]
         * (i.e. `rootProject.rootDir`).
         */
        fun load(gradleRootDir: File): GodotConfig {
            val file = gradleRootDir.resolve("config/godot.properties")
            check(file.exists()) { "Godot properties file not found: ${file.absolutePath}" }
            val props = Properties().also { it.load(file.inputStream()) }
            return GodotConfig(
                godotVersion     = props.require("godotVersion"),
                godotReleaseType = props.require("godotReleaseType"),
            )
        }
    }
}

private fun Properties.require(key: String): String =
    getProperty(key)?.trim()
        ?: error("Required key '$key' is missing from godot.properties.")
