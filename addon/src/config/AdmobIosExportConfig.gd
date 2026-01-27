#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdmobIosExportConfig extends AdmobExportConfig

const IOS_CONFIG_FILE_PATH: String = "res://addons/" + PLUGIN_NAME + "/ios_export.cfg"

const CONFIG_FILE_SECTION_ATT: String = "ATT"

const CONFIG_FILE_KEY_ATT_ENABLED: String = "att_enabled"
const CONFIG_FILE_KEY_ATT_TEXT: String = "att_text"

var att_enabled: bool
var att_text: String


func get_config_file_path() -> String:
	return IOS_CONFIG_FILE_PATH


func load_platform_specific_export_config_from_file(a_config_file: ConfigFile) -> Error:
	att_enabled = a_config_file.get_value(CONFIG_FILE_SECTION_ATT, CONFIG_FILE_KEY_ATT_ENABLED, false)
	att_text = a_config_file.get_value(CONFIG_FILE_SECTION_ATT, CONFIG_FILE_KEY_ATT_TEXT)

	return Error.OK


func load_platform_specific_export_config_from_node(a_node: Admob) -> Error:
	debug_application_id = a_node.ios_debug_application_id
	real_application_id = a_node.ios_real_application_id
	att_enabled = a_node.att_enabled
	att_text = a_node.att_text

	return Error.OK


func print_loaded_config() -> void:
	super.print_loaded_config()
	Admob.log_info("... debug_application_id: %s" % debug_application_id)
	Admob.log_info("... real_application_id: %s" % real_application_id)
	Admob.log_info("... att_enabled: %s" % ("true" if att_enabled else "false"))
	Admob.log_info("... att_text: %s" % att_text)
