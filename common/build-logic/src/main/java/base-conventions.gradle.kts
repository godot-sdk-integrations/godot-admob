//
// © 2026-present https://github.com/cengiz-pz
//

// base-conventions - precompiled script plugin
// (build-logic/src/main/kotlin/base-conventions.gradle.kts)
//
// This is the single entry point for all shared build configuration.
// Applying id("base-conventions") in any project build script:
//
//   1. Makes PluginConfig, GodotConfig, IosConfig, BuildConfig, and the
//      Project extension functions (loadPluginConfig, loadIosConfig, …)
//      available on the build script's compilation classpath.
//
//   2. Bridges every config value onto project.extra so the small number of
//      apply(from = …) scripts that still exist (settings.gradle.kts helpers)
//      can reach them without referencing build-logic types directly.
//
//   3. Sets shared directory-layout extras used across all modules.
//
//   4. Applies the per-module user-defined extra properties and extra Gradle
//      scripts from BuildConfig, keyed by project.path.
//
// The four apply(from = …) scripts that previously held this logic
// (addon.gradle.kts, android.gradle.kts, common.gradle.kts, ios.gradle.kts)
// have been deleted; their logic lives here.

// -- Load all configs ----------------------------------------------------------
//
// These calls are safe here because this IS a precompiled script plugin -
// the build-logic compiled classes are on this file's own classpath.

val pluginConfig = PluginConfig.load(rootProject.rootDir)
val godotConfig  = GodotConfig.load(rootProject.rootDir)
val iosConfig    = IosConfig.load(rootProject.rootDir)
val buildConfig  = BuildConfig.load(rootProject.rootDir)

// -- PluginConfig -> project.extra ---------------------------------------------

project.extra["pluginNodeName"]            = pluginConfig.pluginNodeName
project.extra["pluginName"]                = pluginConfig.pluginName
project.extra["pluginPackageName"]         = pluginConfig.pluginPackageName
project.extra["pluginVersion"]             = pluginConfig.pluginVersion
project.extra["pluginModuleName"]          = pluginConfig.pluginModuleName
project.extra["iosInitializationMethod"]   = pluginConfig.iosInitializationMethod
project.extra["iosDeinitializationMethod"] = pluginConfig.iosDeinitializationMethod

// -- GodotConfig -> project.extra ----------------------------------------------

project.extra["godotVersion"]     = godotConfig.godotVersion
project.extra["godotReleaseType"] = godotConfig.godotReleaseType
project.extra["godotAarUrl"]      = godotConfig.godotAarUrl
project.extra["godotAarFile"]     = godotConfig.godotAarFile

// -- IosConfig -> project.extra -------------------------------------------------
//
// Bridged here so task lambdas that cannot reference IosConfig by type can still
// reach the values via project.extra.  frameworks, embeddedFrameworks, linkerFlags,
// and spmDependencies are stored as List<*> - already parsed by IosConfig.load().

project.extra["iosPlatformVersion"]    = iosConfig.platformVersion
project.extra["iosSwiftVersion"]       = iosConfig.swiftVersion
project.extra["iosFrameworks"]         = iosConfig.frameworks         // List<String>
project.extra["iosEmbeddedFrameworks"] = iosConfig.embeddedFrameworks // List<String>
project.extra["iosLinkerFlags"]        = iosConfig.linkerFlags        // List<String>
project.extra["iosBundleFiles"]        = iosConfig.bundleFiles        // List<String>
project.extra["iosSpmDependencies"]    = iosConfig.spmDependencies    // List<SpmDependency>

// -- Shared directory layout (replaces common.gradle.kts) ---------------------
//
// rootProject.rootDir == gradle/
// rootProject.rootDir.parentFile == repo root

val repoRoot = rootProject.rootDir.parentFile

project.extra["pluginDir"]         = "${rootProject.rootDir}/build/plugin"
project.extra["repositoryRootDir"] = "$repoRoot"
project.extra["archiveDir"]        = "$repoRoot/release"
project.extra["demoDir"]           = "$repoRoot/demo"
project.extra["pluginArchiveMulti"] =
    "${pluginConfig.pluginName}-Multi-v${pluginConfig.pluginVersion}.zip"

// -- Addon source / output layout ----------------------------------------------
//
// projectDir resolves to the correct module directory for each sub-project
// (e.g. addon/, android/, ios/) so templateDir / outputDir are always right.
// Setting these for every project is harmless - android and ios tasks never
// read templateDir or outputDir.

project.extra["templateDir"]       = "$projectDir/src/main"
project.extra["sharedTemplateDir"] = "$projectDir/src/shared"
project.extra["outputDir"]         = "$projectDir/build/output"

// -- Per-module archive names and user-defined extras -------------------------
//
// Conditional on project.path so each module only receives its own extras.
// The root project receives rootExtraProperties / rootExtraGradle.

when (project.path) {
    ":" ->
        applyBuildConfigExtras(buildConfig.rootExtraProperties, buildConfig.rootExtraGradle)

    ":addon" ->
        applyBuildConfigExtras(buildConfig.addonExtraProperties, buildConfig.addonExtraGradle)

    ":android" -> {
        project.extra["pluginArchiveAndroid"] =
            "${pluginConfig.pluginName}-Android-v${pluginConfig.pluginVersion}.zip"
        applyBuildConfigExtras(buildConfig.androidExtraProperties, buildConfig.androidExtraGradle)
    }

    ":ios" -> {
        project.extra["pluginArchiveiOS"] =
            "${pluginConfig.pluginName}-iOS-v${pluginConfig.pluginVersion}.zip"
        applyBuildConfigExtras(buildConfig.iosExtraProperties, buildConfig.iosExtraGradle)
    }
}
