//
// © 2024-present https://github.com/cengiz-pz
//

import com.android.build.gradle.internal.api.LibraryVariantOutputImpl
import com.github.gradle.node.npm.task.NpmTask
import com.github.gradle.node.npm.task.NpxTask
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

plugins {
    id("base-conventions")
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.undercouch.download)
    alias(libs.plugins.openrewrite)
    alias(libs.plugins.node)
}

// ── Load config data classes ──────────────────────────────────────────────────
//
// pluginDir, repositoryRootDir, archiveDir, demoDir, pluginArchiveAndroid and all
// other shared extras are already set on project.extra by base-conventions.
// The typed data classes are loaded here for clean, cast-free member access in
// the android {} block, dependencies {}, and task registration bodies.

val pluginConfig = loadPluginConfig()
val godotConfig = loadGodotConfig()

// ── OpenRewrite ───────────────────────────────────────────────────────────────

configure<org.openrewrite.gradle.RewriteExtension> {
    activeRecipe(
        "org.openrewrite.java.RemoveUnusedImports",
        "org.openrewrite.java.format.AutoFormat",
        "org.openrewrite.java.format.EmptyNewlineAtEndOfFile",
        "org.openrewrite.java.format.RemoveTrailingWhitespace",
        "org.openrewrite.staticanalysis.NeedBraces",
        "org.openrewrite.staticanalysis.WhileInsteadOfFor",
    )
    activeStyle("org.godotengine.plugin.JavaStyle")
    configFile = projectDir.resolve("config/rewrite.yml")
}

// ── Android configuration ─────────────────────────────────────────────────────

android {
    namespace = pluginConfig.pluginPackageName
    compileSdk =
        libs.versions.compileSdk
            .get()
            .toInt()
    buildToolsVersion = libs.versions.buildTools.get()

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        minSdk =
            libs.versions.minSdk
                .get()
                .toInt()
        manifestPlaceholders["godotPluginName"] = pluginConfig.pluginName
        manifestPlaceholders["godotPluginPackageName"] = pluginConfig.pluginPackageName
        buildConfigField("String", "GODOT_PLUGIN_NAME", "\"${pluginConfig.pluginName}\"")
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

    libraryVariants.all {
        outputs.all {
            (this as LibraryVariantOutputImpl).outputFileName =
                "${pluginConfig.pluginName}-$name.aar"
        }
    }
}

androidComponents {
    beforeVariants(selector().all()) { variantBuilder ->
        (variantBuilder as com.android.build.api.variant.HasHostTestsBuilder)
            .hostTests[com.android.build.api.variant.HostTestBuilder.UNIT_TEST_TYPE]
            ?.enable = false
        variantBuilder.androidTest.enable = false
    }
}

node {
    download = true
    version =
        libs.versions.node.env
            .get()
}

// ── Dependencies ──────────────────────────────────────────────────────────────

val androidDependencies =
    extensions
        .getByType<VersionCatalogsExtension>()
        .named("libs")
        .run {
            libraryAliases
                .filter { it != "rewrite.static.analysis" }
                .map { findLibrary(it).get().get() }
        }

dependencies {
    "rewrite"(libs.rewrite.static.analysis)
    implementation("godot:godot-lib:${godotConfig.godotVersion}.${godotConfig.godotReleaseType}@aar")
    androidDependencies.forEach { implementation(it) }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

fun buildTimestamp(): String = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"))

/** Registers a Copy task that assembles one build variant of the Android plugin. */
fun TaskContainerScope.registerAndroidBuildVariant(variant: String) {
    val taskName = "buildAndroid${variant.replaceFirstChar { it.uppercase() }}"
    val pluginDir: String by project.extra
    val repositoryRootDir: String by project.extra

    register<Copy>(taskName) {
        description = "Copies the generated GDScript and $variant AAR binary to the plugin directory"
        group = "build"

        dependsOn(
            project(":addon").tasks.named("generateGDScript"),
            project(":addon").tasks.named("copyAssets"),
            project(":android").tasks.named("assemble${variant.replaceFirstChar { it.uppercase() }}"),
        )

        inputs.files(project(":addon").tasks.named("generateGDScript").map { it.outputs.files })
        inputs.files(project(":addon").tasks.named("copyAssets").map { it.outputs.files })
        inputs.files(
            project(":android")
                .tasks
                .named("assemble${variant.replaceFirstChar { it.uppercase() }}")
                .map { it.outputs.files },
        )

        into("$pluginDir/android")

        from("$repositoryRootDir/addon/build/output") {
            include("addons/${pluginConfig.pluginName}/**")
            include("addons/GMPShared/**")
        }

        from("$projectDir/build/outputs/aar") {
            include("${pluginConfig.pluginName}-$variant.aar")
            into("addons/${pluginConfig.pluginName}/bin/$variant")
        }

        doLast { println("Android $variant build completed at: ${buildTimestamp()}") }

        outputs.dir("$pluginDir/android")
    }
}

// ── Tasks ─────────────────────────────────────────────────────────────────────

tasks {
    val pluginDir: String by project.extra
    val repositoryRootDir: String by project.extra
    val archiveDir: String by project.extra
    val demoDir: String by project.extra

    registerAndroidBuildVariant("debug")
    registerAndroidBuildVariant("release")

    register("buildAndroid") {
        description = "Builds both debug and release"
        group = "build"
        dependsOn("buildAndroidDebug", "buildAndroidRelease")
    }

    register<Zip>("createAndroidArchive") {
        dependsOn("buildAndroidDebug", "buildAndroidRelease")

        group = "archive"
        archiveFileName.set("${pluginConfig.pluginName}-Android-v${pluginConfig.pluginVersion}.zip")
        destinationDirectory.set(layout.projectDirectory.dir(archiveDir))

        into("res") {
            from(layout.projectDirectory.dir("$pluginDir/android")) { includeEmptyDirs = false }
        }

        doLast { println("Android zip archive created at: ${archiveFile.get().asFile.path}") }
    }

    register<Copy>("installToDemoAndroid") {
        description = "Copies the assembled Android plugin to demo application's addons directory"
        group = "install"

        dependsOn(
            project(":addon").tasks.named("generateGDScript"),
            project(":addon").tasks.named("copyAssets"),
            "buildAndroidDebug",
        )

        inputs.files(project.tasks.named("buildAndroidDebug").map { it.outputs.files })

        destinationDir = file(demoDir)
        duplicatesStrategy = DuplicatesStrategy.WARN

        into(".") { from("$pluginDir/android") }

        outputs.dir(destinationDir)
    }

    register<Delete>("uninstallAndroid") {
        description = "Removes plugin files from demo app (preserves .uid and .import files)"
        group = "uninstall"
        delete(
            fileTree("$demoDir/addons/${pluginConfig.pluginName}") {
                include("**/*")
                exclude("**/*.uid")
                exclude("**/*.import")
            },
        )
    }

    register<NpmTask>("installPrettier") {
        group = "setup"
        args.set(listOf("install", "--save-dev", "prettier", "@prettier/plugin-xml"))
    }

    register<NpxTask>("checkXmlFormat") {
        dependsOn("installPrettier")
        command.set("prettier")
        args.set(
            listOf(
                "--config",
                "../.github/config/prettier.xml.json",
                "--parser",
                "xml",
                "--check",
                "src/**/*.xml",
            ),
        )
    }

    register<NpxTask>("formatXml") {
        dependsOn("installPrettier")
        command.set("prettier")
        args.set(
            listOf(
                "--config",
                "../.github/config/prettier.xml.json",
                "--parser",
                "xml",
                "--write",
                "src/**/*.xml",
            ),
        )
    }

    register<de.undercouch.gradle.tasks.download.Download>("downloadCheckstyleJar") {
        group = "setup"
        val checkstyleVersion = libs.versions.checkstyle.get()
        val destFile = file("${gradle.extra["libDir"]}/checkstyle-$checkstyleVersion-all.jar")

        inputs.property("checkstyleVersion", checkstyleVersion)
        outputs.file(destFile)

        src(
            "https://github.com/checkstyle/checkstyle/releases/download/" +
                "checkstyle-$checkstyleVersion/checkstyle-$checkstyleVersion-all.jar",
        )
        dest(destFile)
        overwrite(false)
    }

    register<JavaExec>("checkJavaFormat") {
        description = "Runs Checkstyle on all Java sources under \$projectDir/src"
        group = "verification"

        dependsOn("downloadCheckstyleJar")

        val checkstyleVersion = libs.versions.checkstyle.get()
        val jarFile = file("${gradle.extra["libDir"]}/checkstyle-$checkstyleVersion-all.jar")

        classpath = files(jarFile)
        mainClass.set("com.puppycrawl.tools.checkstyle.Main")
        args =
            listOf(
                "-c",
                rootProject.file("../.github/config/checkstyle.xml").absolutePath,
                file("$projectDir/src").absolutePath,
            )

        inputs.dir("$projectDir/src")
        inputs.file(rootProject.file("../.github/config/checkstyle.xml"))
        outputs.upToDateWhen { false }
    }

    register<de.undercouch.gradle.tasks.download.Download>("downloadGodotAar") {
        group = "setup"
        val destFile = file("${gradle.extra["libDir"]}/${godotConfig.godotAarFile}")

        inputs.property("godotAarUrl", godotConfig.godotAarUrl)
        outputs.file(destFile)

        src(godotConfig.godotAarUrl)
        dest(destFile)
        overwrite(false)
    }

    named("preBuild") {
        dependsOn("downloadGodotAar")
    }
}
