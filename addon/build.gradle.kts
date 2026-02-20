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
		dependsOn("cleanOutput")
		finalizedBy("copyAssets")

		inputs.file(rootProject.file("config/config.properties"))
		inputs.file(rootProject.file("../ios/config/config.properties")).withPropertyName("iosConfig")

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
	}

	register<Copy>("generateiOSConfig") {
		description = "Copies the iOS plugin config to the output directory and replaces tokens"

		inputs.file(rootProject.file("config/config.properties"))
		inputs.file(rootProject.file("../ios/config/config.properties")).withPropertyName("iosConfig")

		from("../ios/config")
		into("${project.extra["outputDir"]}/ios/plugins")

		include("**/*.gdip")

		// Explicit tokens map
		val explicitTokens = mapOf(
			"pluginName" to (project.extra["pluginName"] as String),
			"iosInitializationMethod" to (project.extra["iosInitializationMethod"] as String),
			"iosDeinitializationMethod" to (project.extra["iosDeinitializationMethod"] as String)
		)

		// Print file name before processing
		eachFile {
			println("[DEBUG] Processing file: ${relativePath}")
		}

		// Token replacement
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
	}

	// Ensure generateiOSConfig always runs after generateGDScript
	// (token replacement order matters for the final plugin files)
	named<Copy>("generateiOSConfig") {
		mustRunAfter("generateGDScript")
	}
}
