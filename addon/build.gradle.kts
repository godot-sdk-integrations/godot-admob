//
// © 2024-present https://github.com/cengiz-pz
//

import org.apache.tools.ant.filters.ReplaceTokens

apply(from = "${projectDir}/config.gradle.kts")

// Access the library catalog by name ("libs")
val catalog = extensions.getByType<VersionCatalogsExtension>().named("libs")

// Map all library aliases to their actual dependency provider
val androidDependencies = catalog.libraryAliases.map { alias ->
	catalog.findLibrary(alias).get().get()
}

tasks {
	register<Delete>("cleanOutput") {
		// Keep the directory itself and delete files with specified type inside
		delete(fileTree("${project.extra["outputDir"]}/${project.extra["pluginName"]}").apply {
			include("**/*.gd")
			include("**/*.cfg")
			include("**/*.png")
		})
	}

	register<Copy>("copyAssets") {
		description = "Copies plugin assets such as PNG images to the output directory"
		from(project.extra["templateDirectory"] as String)
		into("${project.extra["outputDir"]}/addons/${project.extra["pluginName"]}")
		include("**/*.png")
	}

	register<Copy>("generateGDScript") {
		description = "Copies the GDScript templates and plugin config to the output directory and replaces tokens"
		finalizedBy("copyAssets")

		from(project.extra["templateDirectory"] as String)
		into("${project.extra["outputDir"]}/addons/${project.extra["pluginName"]}")

		include("**/*.gd")
		include("**/*.cfg")

		// Explicit tokens map
		val explicitTokens = mapOf(
			"pluginName" to (project.extra["pluginName"] as String),
			"pluginNodeName" to (project.extra["pluginNodeName"] as String),
			"pluginVersion" to (project.extra["pluginVersion"] as String),
			"pluginPackage" to (project.extra["pluginPackageName"] as String),
			"androidDependencies" to androidDependencies.joinToString(", ") { "\"$it\"" },
			"iosPlatformVersion" to (project.extra["iosPlatformVersion"] as String),
			"iosFrameworks" to (project.extra["iosFrameworks"] as String)
				.split(",")
				.map { it.trim() }
				.filter { it.isNotBlank() }
				.joinToString(", ") { "\"$it\"" },
			"iosEmbeddedFrameworks" to (project.extra["iosEmbeddedFrameworks"] as String)
				.split(",")
				.map { it.trim() }
				.filter { it.isNotBlank() }
				.joinToString(", ") { "\"$it\"" },
			"iosLinkerFlags" to (project.extra["iosLinkerFlags"] as String)
				.split(",")
				.map { it.trim() }
				.filter { it.isNotBlank() }
				.joinToString(", ") { "\"$it\"" }
		)

		// Print file name before processing
		eachFile {
			println("[DEBUG] Processing file: ${relativePath}")
		}

		// First pass: replacement for explicit tokens
		filter { line: String ->
			var result = line

			explicitTokens.forEach { (key, value) ->
				val token = "@$key@"
				if (result.contains(token)) {
					println("	[DEBUG] Replacing token $token with: $value")
					result = result.replace(token, value)
				}
			}

			result
		}

		// Second pass: generic replacement for extra tokens (ie. extra.myProperty=...)
		filter { line: String ->
			var result = line

			project.extra.properties.forEach { (key, value) ->
				val token = "@$key@"
				if (result.contains(token)) {
					val valueString = value.toString()
					val replacedValue =
						if (valueString.contains(",")) {
							valueString.split(",")
								.map { it.trim() }
								.filter { it.isNotBlank() }
								.joinToString(", ") { "\"$it\"" }
						} else {
							valueString
						}

					println("	[DEBUG] Replacing token $token with: $replacedValue")
					result = result.replace(token, replacedValue)
				}
			}

			result
		}

		inputs.dir(project.extra["templateDirectory"] as String)
		inputs.files(
			rootProject.file("config/config.properties"),
			rootProject.file("../ios/config/config.properties")
		)

		// Declare every token that appears in templates
		inputs.property("pluginName", project.extra["pluginName"])
		inputs.property("pluginNodeName", project.extra["pluginNodeName"])
		inputs.property("pluginVersion", project.extra["pluginVersion"])
		inputs.property("pluginPackage", project.extra["pluginPackageName"])
		inputs.property("androidDependencies", androidDependencies.joinToString())
		inputs.property("iosPlatformVersion", project.extra["iosPlatformVersion"])
		inputs.property("iosFrameworks", project.extra["iosFrameworks"])
		inputs.property("iosEmbeddedFrameworks", project.extra["iosEmbeddedFrameworks"])
		inputs.property("iosLinkerFlags", project.extra["iosLinkerFlags"])

		outputs.dir("${project.extra["outputDir"]}/addons/${project.extra["pluginName"]}")
	}

	register<Copy>("generateiOSConfig") {
		description = "Copies the iOS plugin config to the output directory and replaces tokens"

		from("${rootProject.projectDir}/../ios/config")
		into("${project.extra["outputDir"]}/ios/plugins")

		include("**/*.gdip")

		// Explicit tokens map
		val explicitTokens = mapOf(
			"pluginName" to (project.extra["pluginName"] as String),
			"iosInitializationMethod" to (project.extra["iosInitializationMethod"] as String),
			"iosDeinitializationMethod" to (project.extra["iosDeinitializationMethod"] as String)
		)

		eachFile {
			println("[DEBUG] Processing file: ${relativePath}")
		}

		filter { line: String ->
			var result = line
			explicitTokens.forEach { (key, value) ->
				val token = "@$key@"
				if (result.contains(token)) {
					println("	[DEBUG] Replacing token $token with: $value")
					result = result.replace(token, value)
				}
			}
			result
		}

		inputs.files(
			rootProject.file("config/config.properties"),
			rootProject.file("../ios/config/config.properties")
		)

		inputs.property("pluginName", project.extra["pluginName"])
		inputs.property("iosInitializationMethod", project.extra["iosInitializationMethod"])
		inputs.property("iosDeinitializationMethod", project.extra["iosDeinitializationMethod"])

		outputs.dir("${project.extra["outputDir"]}/ios/plugins")
	}

	// Ensure generateiOSConfig always runs after generateGDScript
	// (token replacement order matters for the final plugin files)
	named<Copy>("generateiOSConfig") {
		mustRunAfter("generateGDScript")
	}
}
