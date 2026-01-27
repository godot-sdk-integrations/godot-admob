//
// © 2024-present https://github.com/cengiz-pz
//

import java.util.Properties
import java.io.FileInputStream

val commonProperties = Properties().apply {
	load(FileInputStream("${rootDir}/config/config.properties"))
}

val iosProperties = Properties().apply {
	load(FileInputStream("${rootDir}/../ios/config/config.properties"))
}

extra.apply {
	// Apply extra gradle build files that are configured to be applied
	commonProperties.forEach { entry ->
		val key = entry.key.toString()
		if (key.startsWith("gradle.")) {
			val fileName = entry.value.toString().trim()
			if (fileName.isNotBlank()) {
				val relativePath = if (fileName.startsWith("/")) fileName else "./$fileName"
				apply(from = relativePath)
				println("[config] Applied extra script: $fileName (from property $key)")
			}
		} else if (key.startsWith("extra.")) {
			val propertyName = key.removePrefix("extra.")
			val propertyValue = entry.value.toString()
			set(propertyName, propertyValue)
				println("[config] Set extra property: $propertyName to $propertyValue")
		}
	}

	set("templateDirectory", "${projectDir}/src")
	set("buildDir", "${projectDir}/build")
	set("outputDir", "${get("buildDir")}/output")

	// Plugin details
	set("pluginNodeName", commonProperties.getProperty("pluginNodeName"))
	set("pluginName", "${get("pluginNodeName")}Plugin")
	set("pluginPackageName", "org.godotengine.plugin.admob")
	set("pluginVersion", commonProperties.getProperty("pluginVersion"))
	set("pluginArchive", "${get("pluginName")}-Android-v${get("pluginVersion")}.zip")

	// iOS
	set("iosPlatformVersion", iosProperties.getProperty("platform_version"))
	set("iosFrameworks", iosProperties.getProperty("frameworks"))
	set("iosEmbeddedFrameworks", iosProperties.getProperty("embedded_frameworks"))
	set("iosLinkerFlags", iosProperties.getProperty("flags"))
}
