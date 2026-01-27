//
// © 2024-present https://github.com/cengiz-pz
//

import java.util.Properties
import java.io.FileInputStream

tasks {
	register("replaceMediationTokens") {
		description = "Replaces mediation tokens in MediationNetwork.gd with values from mediation.properties"
		dependsOn("generateGDScript")

		doLast {
			// Load properties file
			val mediationProps = Properties().apply {
				load(FileInputStream(file("${rootDir}/config/mediation.properties")))
			}

			// Setup files and content
			val gdFile = file("${project.extra["outputDir"]}/${project.extra["pluginName"]}/model/MediationNetwork.gd")
			if (!gdFile.exists()) {
				println("[WARNING] MediationNetwork.gd not found at ${gdFile.absolutePath}, skipping replacement.")
				return@doLast
			}

			// Read raw file content with tokens
			val content = gdFile.readText()
			var newContent = content

			val networks = mediationProps.stringPropertyNames()
				.filter { it.contains(".") }
				.map { it.substringBefore(".") }
				.distinct()
				.sorted()

			for (network in networks) {
				// Prepare replacements
				val depsStr = mediationProps.getProperty("${network}.dependencies") ?: ""
				val deps = if (depsStr.isNotEmpty()) {
					depsStr.split(",").map { "\"${it.trim()}\"" }.joinToString(", ")
				} else {
					""
				}
				val repo = mediationProps.getProperty("${network}.mavenRepo") ?: ""
				val andAdapter = mediationProps.getProperty("${network}.androidAdapterClass") ?: ""
				val iosAdapter = mediationProps.getProperty("${network}.iosAdapterClass") ?: ""
				val pod = mediationProps.getProperty("${network}.pod") ?: ""
				val podVer = mediationProps.getProperty("${network}.podVersion") ?: ""
				val skIdsStr = mediationProps.getProperty("${network}.skAdNetworkIds") ?: ""
				val skIds = if (skIdsStr.isNotEmpty()) {
					skIdsStr.split(",").map { "\"${it.trim()}\"" }.joinToString(", ")
				} else {
					""
				}

				// Replace tokens
				newContent = newContent
					.replace("@${network}Dependencies@", deps)
					.replace("@${network}MavenRepo@", repo)
					.replace("@${network}AndroidAdapterClass@", andAdapter)
					.replace("@${network}IosAdapterClass@", iosAdapter)
					.replace("@${network}Pod@", pod)
					.replace("@${network}PodVersion@", podVer)
					.replace("@${network}SkAdNetworkIds@", skIds)
			}

			// Write updated content with tokens replaced
			gdFile.writeText(newContent)
			println("[INFO] Mediation tokens replaced in ${gdFile.absolutePath}")
		}
	}
}

afterEvaluate {
	listOf("generateGDScript").forEach { taskName ->
		tasks.named(taskName).configure {
			finalizedBy("replaceMediationTokens")
		}
	}
}
