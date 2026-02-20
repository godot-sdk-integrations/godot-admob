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
	set("pluginModuleName", "${commonProperties.getProperty("pluginModuleName")}")
	set("pluginPackageName", commonProperties.getProperty("pluginPackage"))
	set("pluginVersion", commonProperties.getProperty("pluginVersion"))
	set("pluginArchiveAndroid", "${get("pluginName")}-Android-v${get("pluginVersion")}.zip")
	set("pluginArchiveiOS", "${get("pluginName")}-iOS-v${get("pluginVersion")}.zip")
	set("pluginArchiveMulti", "${get("pluginName")}-Multi-v${get("pluginVersion")}.zip")

	set("pluginDir", "${rootDir}/build/plugin")
	set("archiveDir", "${rootDir}/../release")
	set("iosDir", "${rootDir}/../ios")

	// Demo
	set("demoDir", "${rootDir}/../demo")
}
