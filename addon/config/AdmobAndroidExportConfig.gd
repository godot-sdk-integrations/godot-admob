#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdmobAndroidExportConfig extends AdmobExportConfig

const ANDROID_CONFIG_FILE_PATH: String = "res://addons/" + PLUGIN_NAME + "/android_export.cfg"


func get_config_file_path() -> String:
	return ANDROID_CONFIG_FILE_PATH
