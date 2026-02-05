//
// © 2024-present https://github.com/cengiz-pz
//

import java.util.Properties
import java.io.FileInputStream

val commonProperties = Properties().apply {
	load(FileInputStream("${rootDir}/config/config.properties"))
}

extra.apply {
	// Plugin details
	set("pluginNodeName", commonProperties.getProperty("pluginNodeName"))
	set("pluginName", "${get("pluginNodeName")}Plugin")
	set("pluginPackageName", commonProperties.getProperty("pluginPackage"))
	set("pluginVersion", commonProperties.getProperty("pluginVersion"))
	set("pluginArchive", "${get("pluginName")}-Android-v${get("pluginVersion")}.zip")

	set("pluginDir", "${rootDir}/build/plugin")
	set("archiveDir", "${rootDir}/build/archive")

	// Demo
	set("demoDir", "${rootDir}/../demo")
}
