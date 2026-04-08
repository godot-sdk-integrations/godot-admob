//
// © 2024-present https://github.com/cengiz-pz
//

import com.android.build.gradle.internal.api.LibraryVariantOutputImpl
import com.github.gradle.node.npm.task.NpmTask
import com.github.gradle.node.npm.task.NpxTask
import org.w3c.dom.Element
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import javax.xml.parsers.DocumentBuilderFactory

plugins {
    id("base-conventions")
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.undercouch.download)
    alias(libs.plugins.openrewrite)
    alias(libs.plugins.node)
}

// -- Load config data classes --------------------------------------------------

val pluginConfig = loadPluginConfig()
val godotConfig = loadGodotConfig()

// -- Test-report data types ----------------------------------------------------
//
// Defined at the top level so they are visible inside every task doLast closure.

data class SuiteResult(
    val name: String,
    val tests: Int,
    val passed: Int,
    val failed: Int,
    val skipped: Int,
)

data class CoverageCounter(
    val type: String,
    val covered: Long,
    val missed: Long,
) {
    val total: Long = covered + missed
    val pct: Double = if (total == 0L) 100.0 else covered * 100.0 / total
}

// -- Test-report helper functions ----------------------------------------------

/**
 * Returns a DocumentBuilder that will not attempt any network or filesystem
 * access to resolve external DTD or entity declarations. JaCoCo's XML report
 * contains a DOCTYPE declaration that references "report.dtd"; suppressing
 * external entity loading prevents IO errors when parsing offline.
 */
fun safeXmlBuilder(): javax.xml.parsers.DocumentBuilder {
    val factory = DocumentBuilderFactory.newInstance()
    try {
        factory.isValidating = false
        factory.isNamespaceAware = false
        factory.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false)
        factory.setFeature("http://xml.org/sax/features/external-general-entities", false)
        factory.setFeature("http://xml.org/sax/features/external-parameter-entities", false)
    } catch (_: Exception) {
        // Swallow: some parser implementations don't expose these features.
    }
    return factory.newDocumentBuilder()
}

/**
 * Parses every JUnit-format XML file in [resultsDir] and returns one
 * [SuiteResult] per file, sorted alphabetically by the simple class name.
 * Malformed or unreadable files are silently skipped.
 */
fun parseSuiteResults(resultsDir: File): List<SuiteResult> {
    if (!resultsDir.exists()) return emptyList()
    val builder = safeXmlBuilder()
    return (resultsDir.listFiles { f -> f.extension == "xml" } ?: emptyArray())
        .mapNotNull { file ->
            runCatching {
                val root = builder.parse(file).documentElement
                // The "name" attribute is the fully-qualified class name; strip the package.
                val name = root.getAttribute("name").substringAfterLast('.')
                val tests = root.getAttribute("tests").toIntOrNull() ?: 0
                val failures = root.getAttribute("failures").toIntOrNull() ?: 0
                val errors = root.getAttribute("errors").toIntOrNull() ?: 0
                val skipped = root.getAttribute("skipped").toIntOrNull() ?: 0
                val failed = failures + errors
                SuiteResult(name, tests, maxOf(0, tests - failed - skipped), failed, skipped)
            }.getOrNull()
        }.sortedBy { it.name }
}

/**
 * Parses the top-level `<counter>` elements from a JaCoCo XML report, which
 * represent project-wide totals. Returns only the five counters we display:
 * INSTRUCTION, BRANCH, LINE, METHOD, CLASS.
 */
fun parseCoverage(reportXml: File): List<CoverageCounter> {
    if (!reportXml.exists()) return emptyList()
    return runCatching {
        val root = safeXmlBuilder().parse(reportXml).documentElement
        val order = listOf("INSTRUCTION", "BRANCH", "LINE", "METHOD", "CLASS")
        // Collect only direct <counter> children of the root <report> element;
        // nested counters belong to individual packages/classes and are skipped.
        (0 until root.childNodes.length)
            .mapNotNull { root.childNodes.item(it) as? Element }
            .filter { it.tagName == "counter" }
            .mapNotNull { el ->
                val type = el.getAttribute("type").takeIf { it in order } ?: return@mapNotNull null
                CoverageCounter(
                    type,
                    el.getAttribute("covered").toLongOrNull() ?: 0L,
                    el.getAttribute("missed").toLongOrNull() ?: 0L,
                )
            }.sortedBy { order.indexOf(it.type) }
    }.getOrDefault(emptyList())
}

/**
 * Prints a formatted table of per-suite pass/fail counts to standard output.
 * Returns `true` if any suite has failing tests so the caller can signal a
 * build failure after the full report has been displayed.
 */
fun printTestResultsTable(suites: List<SuiteResult>): Boolean {
    val bar = "=".repeat(80)
    val sep = "-".repeat(80)

    println()
    println(bar)
    println(" TEST RESULTS")
    println(bar)

    if (suites.isEmpty()) {
        println(" No test results found.")
        println(" Expected location: build/test-results/testDebugUnitTest/")
        println(bar)
        println()
        return false
    }

    val nameW = maxOf(suites.maxOf { it.name.length }, "Suite".length)

    println(
        " %-${nameW}s   %5s   %6s   %6s   %6s"
            .format("Suite", "Tests", "Passed", "Failed", "Pass %"),
    )
    println(sep)

    suites.forEach { s ->
        val pct = if (s.tests > 0) s.passed * 100.0 / s.tests else 100.0
        println(
            " %-${nameW}s   %5d   %6d   %6d   %5.1f%%"
                .format(s.name, s.tests, s.passed, s.failed, pct),
        )
    }

    val totalTests = suites.sumOf { it.tests }
    val totalPassed = suites.sumOf { it.passed }
    val totalFailed = suites.sumOf { it.failed }
    val totalPct = if (totalTests > 0) totalPassed * 100.0 / totalTests else 100.0

    println(sep)
    println(
        " %-${nameW}s   %5d   %6d   %6d   %5.1f%%"
            .format("TOTAL", totalTests, totalPassed, totalFailed, totalPct),
    )
    println(bar)
    println()

    return totalFailed > 0
}

/**
 * Prints a formatted table of JaCoCo coverage counters (Instructions, Branches,
 * Lines, Methods, Classes) to standard output. If [counters] is empty a
 * one-line notice is printed instead.
 */
fun printCoverageSummary(
    counters: List<CoverageCounter>,
    reportDir: File,
) {
    val bar = "=".repeat(80)
    val sep = "-".repeat(80)

    val labelMap =
        mapOf(
            "INSTRUCTION" to "Instructions",
            "BRANCH" to "Branches",
            "LINE" to "Lines",
            "METHOD" to "Methods",
            "CLASS" to "Classes",
        )

    println(bar)
    println(" CODE COVERAGE")
    if (reportDir.exists()) {
        println(" HTML report: ${File(reportDir, "index.html").absolutePath}")
    }
    println(bar)

    if (counters.isEmpty()) {
        println(" Coverage data not available.")
        println(" Expected location: build/reports/coverage/test/debug/report.xml")
        println(bar)
        println()
        return
    }

    println(
        " %-15s   %7s   %7s   %7s   %8s"
            .format("Metric", "Covered", "Missed", "Total", "Coverage"),
    )
    println(sep)

    counters.forEach { c ->
        println(
            " %-15s   %7d   %7d   %7d   %7.1f%%"
                .format(labelMap[c.type] ?: c.type, c.covered, c.missed, c.total, c.pct),
        )
    }

    println(bar)
    println()
}

// -- OpenRewrite ---------------------------------------------------------------

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

// -- Android configuration -----------------------------------------------------

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

    buildTypes {
        // enableUnitTestCoverage instruments testDebugUnitTest with the JaCoCo
        // agent and wires up the createDebugUnitTestCoverageReport task, which
        // produces the XML report that printTestSummary reads.
        debug {
            enableUnitTestCoverage = true
        }
    }

    testOptions {
        unitTests {
            // Return 0 / false / null for every un-mocked Android framework call
            // (Log.d, Log.e, Log.i, Settings.Secure, etc.) instead of throwing.
            isReturnDefaultValues = true
        }
    }
}

node {
    download = true
    version =
        libs.versions.node.env
            .get()
}

// -- Dependencies --------------------------------------------------------------

val androidDependencies =
    extensions
        .getByType<VersionCatalogsExtension>()
        .named("libs")
        .run {
            libraryAliases
                .filter { it != "rewrite.static.analysis" && !it.startsWith("test.") }
                .map { findLibrary(it).get().get() }
        }

val testDependencies =
    extensions
        .getByType<VersionCatalogsExtension>()
        .named("libs")
        .run {
            libraryAliases
                .filter { it.startsWith("test.") && !it.startsWith("test.runtime.") }
                .map { findLibrary(it).get().get() }
        }

val testRuntimeOnlyDependencies =
    extensions.getByType<VersionCatalogsExtension>().named("libs").run {
        libraryAliases
            .filter { it.startsWith("test.runtime.") }
            .map { findLibrary(it).get().get() }
    }

dependencies {
    "rewrite"(libs.rewrite.static.analysis)
    implementation("godot:godot-lib:${godotConfig.godotVersion}.${godotConfig.godotReleaseType}@aar")
    androidDependencies.forEach { implementation(it) }
    testDependencies.forEach { testImplementation(it) }
    testRuntimeOnlyDependencies.forEach { testRuntimeOnly(it) }
}

// -- Helpers -------------------------------------------------------------------

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

// -- Tasks ---------------------------------------------------------------------

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

    // -- Test summary ----------------------------------------------------------

    register("printTestSummary") {
        group = "verification"
        description = "Runs unit tests + coverage and prints a formatted summary to the console"

        // Explicitly depend on both tasks so the full pipeline always runs
        dependsOn("testDebugUnitTest")
        dependsOn("createDebugUnitTestCoverageReport")

        doLast {
            val buildDir =
                project.layout.buildDirectory
                    .get()
                    .asFile
            val resultsDir = File(buildDir, "test-results/testDebugUnitTest")
            val coverageXml = File(buildDir, "reports/coverage/test/debug/report.xml")
            val coverageDir = coverageXml.parentFile

            val suites = parseSuiteResults(resultsDir)
            val counters = parseCoverage(coverageXml)

            val hasFailures = printTestResultsTable(suites)
            printCoverageSummary(counters, coverageDir)

            if (hasFailures) {
                val n = suites.sumOf { it.failed }
                throw GradleException("$n test(s) failed - see the TEST RESULTS table above.")
            }
        }
    }
}

// -- Task wiring ---------------------------------------------------------------

tasks.withType<Test> {
    useJUnitPlatform()
    // Let the full pipeline (coverage + printTestSummary) run even if tests fail.
    // printTestSummary will throw a GradleException if any tests failed.
    ignoreFailures = true
}

// 🔥 Final fix: afterEvaluate guarantees the test task exists when we configure it
afterEvaluate {
    tasks.named<Test>("testDebugUnitTest") {
        // This tells Gradle: coverage report MUST run AFTER the test task finishes
        finalizedBy("createDebugUnitTestCoverageReport")
    }
}
