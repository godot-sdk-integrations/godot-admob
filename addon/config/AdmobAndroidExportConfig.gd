#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdmobAndroidExportConfig extends AdmobExportConfig

const ANDROID_CONFIG_FILE_PATH: String = "res://addons/" + PLUGIN_NAME + "/android_export.cfg"


func get_config_file_path() -> String:
	return ANDROID_CONFIG_FILE_PATH


func load_platform_specific_export_config_from_node(a_node: Admob) -> Error:
	debug_application_id = a_node.android_debug_application_id
	real_application_id = a_node.android_real_application_id

	return Error.OK


func print_loaded_config() -> void:
	super.print_loaded_config()
	Admob.log_info("... debug_application_id: %s" % debug_application_id)
	Admob.log_info("... real_application_id: %s" % real_application_id)
