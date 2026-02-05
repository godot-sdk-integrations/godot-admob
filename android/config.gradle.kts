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

	// Godot
	set("godotVersion", commonProperties.getProperty("godotVersion"))
	set("releaseType", commonProperties.getProperty("godotReleaseType"))
	set("godotAarUrl", "https://github.com/godotengine/godot-builds/releases/download/${get("godotVersion")}-${get("releaseType")}/godot-lib.${get("godotVersion")}.${get("releaseType")}.template_release.aar")
	set("godotAarFile", "godot-lib-${get("godotVersion")}.${get("releaseType")}.aar")
}
