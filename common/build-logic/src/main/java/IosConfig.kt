//
// © 2026-present https://github.com/cengiz-pz
//

import java.io.File
import java.util.Properties
import kotlinx.serialization.json.Json
import kotlinx.serialization.decodeFromString

/**
 * Immutable value object holding every setting from `ios/config/ios.properties`
 * and `ios/config/spm_dependencies.json`.
 *
 * Obtain an instance via [Project.loadIosConfig] (defined in `ProjectExtensions.kt`),
 * which is available in any project build script that applies `id("base-conventions")`:
 *
 * ```kotlin
 * plugins { id("base-conventions") }
 *
 * val iosConfig = loadIosConfig()
 * println(iosConfig.platformVersion)    // "14.3"
 * println(iosConfig.swiftVersion)       // "5.9"
 * println(iosConfig.frameworks)         // ["Foundation.framework", "Network.framework"]
 * println(iosConfig.spmDependencies)    // [SpmDependency(url=..., version=..., products=[...])]
 * ```
 *
 * ## Source files
 *
 * - `ios/config/ios.properties` at the repository root (one level above `gradle/`).
 * - `ios/config/spm_dependencies.json` at the repository root (optional; defaults to an
 *   empty list when absent).
 *
 * ## Properties reference (`ios.properties`)
 *
 * | Property key          | Kotlin field            | Description                                             |
 * |-----------------------|-------------------------|---------------------------------------------------------|
 * | `platform_version`    | [platformVersion]       | Minimum iOS deployment target, e.g. `14.3`              |
 * | `swift_version`       | [swiftVersion]          | Swift language version used by Xcode, e.g. `5.9`        |
 * | `frameworks`          | [frameworks]            | System framework names to link, e.g. `["Foundation.framework"]` |
 * | `embedded_frameworks` | [embeddedFrameworks]    | Frameworks to embed in the app bundle (may be empty)    |
 * | `flags`               | [linkerFlags]           | Extra linker flags, e.g. `["-ObjC"]`                   |
 * | `bundle_files`        | [bundleFiles]           | Files to include in the app bundle, e.g. `["res://afile.task"]` |
 *
 * Comma-separated properties (`frameworks`, `embedded_frameworks`, `flags`) are
 * split into [List]s at load time - blank entries are dropped - so consumers never
 * need to parse delimiters themselves.
 *
 * ## SPM dependencies reference (`spm_dependencies.json`)
 *
 * JSON array of objects; each object maps to a [SpmDependency]:
 * ```json
 * [
 *   { "url": "https://github.com/owner/repo", "version": "1.2.3", "products": ["ProductA"] }
 * ]
 * ```
 *
 * | JSON key    | [SpmDependency] field | Description                                   |
 * |-------------|------------------------|-----------------------------------------------|
 * | `url`       | [SpmDependency.url]    | Git repository URL of the Swift package       |
 * | `version`   | [SpmDependency.version]| Minimum package version requirement           |
 * | `products`  | [SpmDependency.products]| SPM product names to link against            |
 */
data class IosConfig(
    /** Minimum iOS deployment target, e.g. `14.3`. */
    val platformVersion: String,
    /**
     * Swift language version required by the plugin, e.g. `5.9`.
     *
     * May be an empty string if `swift_version` is not set in `ios.properties`.
     * Use [Project.loadIosConfig] together with the `validateSwiftVersion` Gradle task
     * to surface a clear error at build time rather than relying on a non-null guarantee here.
     */
    val swiftVersion: String,
    /**
     * System frameworks to link against, e.g. `["Foundation.framework", "Network.framework"]`.
     *
     * Parsed from the comma-separated `frameworks` key in `ios.properties`.
     * Empty when no frameworks are specified.
     */
    val frameworks: List<String>,
    /**
     * Frameworks to embed in the app bundle.
     *
     * Parsed from the comma-separated `embedded_frameworks` key in `ios.properties`.
     * Empty when no frameworks need embedding.
     */
    val embeddedFrameworks: List<String>,
    /**
     * Extra linker flags passed to `xcodebuild`, e.g. `["-ObjC"]`.
     *
     * Parsed from the comma-separated `flags` key in `ios.properties`.
     * Empty when no extra flags are required.
     */
    val linkerFlags: List<String>,
    /**
     * Files to include in the app bundle.
     *
     * Parsed from the comma-separated `bundle_files` key in `ios.properties`.
     * Empty when no extra files are required.
     */
    val bundleFiles: List<String>,
    /**
     * Swift Package Manager dependencies decoded from `ios/config/spm_dependencies.json`.
     *
     * Each entry carries a package [SpmDependency.url], a minimum [SpmDependency.version],
     * and a list of [SpmDependency.products] to link against.
     * Empty when the JSON file is absent or contains an empty array.
     */
    val spmDependencies: List<SpmDependency>,
    /**
     * xcodebuild `-destination` platform value for unit tests, e.g. `iOS Simulator`.
     *
     * Read from the `test_platform` key in `ios/config/ios.properties`.
     */
    val testPlatform: String,
    /**
     * Simulator or device name used as the xcodebuild `-destination` `name` for unit
     * tests, e.g. `iPhone 17`.
     *
     * Read from the `test_destination_name` key in `ios/config/ios.properties`.
     */
    val testDestinationName: String,
    /**
     * OS version constraint passed as the xcodebuild `-destination` `OS` value,
     * e.g. `latest`.
     *
     * Read from the `test_os` key in `ios/config/ios.properties`.
     */
    val testOs: String,
) {
    companion object {
        /** Lenient [Json] instance - tolerates unknown keys added to the JSON in future. */
        private val json = Json { ignoreUnknownKeys = true }

        /**
         * Loads an [IosConfig] from `ios/config/ios.properties` and
         * (optionally) `ios/config/spm_dependencies.json`.
         *
         * @param gradleRootDir `rootProject.rootDir` - the `gradle/` directory.
         *   The repository root is resolved as `gradleRootDir.parentFile`, and the
         *   config files are expected under `<repoRoot>/ios/config/`.
         */
        fun load(gradleRootDir: File): IosConfig {
            val iosConfigDir = gradleRootDir.parentFile.resolve("ios/config")

            // -- ios.properties ------------------------------------------------
            val propsFile = iosConfigDir.resolve("ios.properties")
            check(propsFile.exists()) { "iOS properties file not found: ${propsFile.absolutePath}" }
            val props = Properties().also { it.load(propsFile.inputStream()) }

            // -- spm_dependencies.json -----------------------------------------
            val spmFile = iosConfigDir.resolve("spm_dependencies.json")
            val spmDependencies: List<SpmDependency> =
                if (spmFile.exists()) {
                    json.decodeFromString(spmFile.readText())
                } else {
                    emptyList()
                }

            return IosConfig(
                platformVersion     = props.require("platform_version"),
                swiftVersion        = props.getProperty("swift_version")?.trim() ?: "",
                frameworks          = props.splitList("frameworks"),
                embeddedFrameworks  = props.splitList("embedded_frameworks"),
                linkerFlags         = props.splitList("flags"),
                bundleFiles         = props.splitList("bundle_files"),
                spmDependencies     = spmDependencies,
                testPlatform        = props.require("test_platform"),
                testDestinationName = props.require("test_destination_name"),
                testOs              = props.require("test_os"),
            )
        }
    }
}

private fun Properties.require(key: String): String =
    getProperty(key)?.trim()
        ?: error("Required key '$key' is missing from ios/config/ios.properties.")

/** Splits a comma-separated property value into a trimmed, non-blank list. */
private fun Properties.splitList(key: String): List<String> =
    getProperty(key)
        ?.split(",")
        ?.map { it.trim() }
        ?.filter { it.isNotBlank() }
        ?: emptyList()
