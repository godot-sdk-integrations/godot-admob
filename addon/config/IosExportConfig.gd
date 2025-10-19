#
# © 2024-present https://github.com/cengiz-pz
#

class_name IosExportConfig extends AdmobExportConfig

const CONFIG_FILE_PATH: String = "res://addons/" + PLUGIN_NAME + "/ios_export.cfg"

const CONFIG_FILE_SECTION_ATT: String = "ATT"

const CONFIG_FILE_KEY_ATT_ENABLED: String = "att_enabled"
const CONFIG_FILE_KEY_ATT_TEXT: String = "att_text"

var att_enabled: bool
var att_text: String


func export_config_file_exists() -> bool:
	return FileAccess.file_exists(CONFIG_FILE_PATH)


func load_export_config_from_file() -> Error:
	Admob.log_info("Loading export config from file!")

	var __result = Error.OK

	var __config_file = ConfigFile.new()

	var __load_result = __config_file.load(CONFIG_FILE_PATH)
	if __load_result == Error.OK:
		is_real = __config_file.get_value(CONFIG_FILE_SECTION_GENERAL, CONFIG_FILE_KEY_IS_REAL)
		debug_application_id = __config_file.get_value(CONFIG_FILE_SECTION_DEBUG, CONFIG_FILE_KEY_APP_ID)
		real_application_id = __config_file.get_value(CONFIG_FILE_SECTION_RELEASE, CONFIG_FILE_KEY_APP_ID)
		att_enabled = __config_file.get_value(CONFIG_FILE_SECTION_ATT, CONFIG_FILE_KEY_ATT_ENABLED, false)
		att_text = __config_file.get_value(CONFIG_FILE_SECTION_ATT, CONFIG_FILE_KEY_ATT_TEXT)

		if is_real == null or debug_application_id == null or real_application_id == null:
			__result == Error.ERR_INVALID_DATA
			Admob.log_error("Invalid export config file %s!" % CONFIG_FILE_PATH)
	else:
		__result = Error.ERR_CANT_OPEN
		Admob.log_error("Failed to open export config file %s!" % CONFIG_FILE_PATH)

	if __result == OK:
		print_loaded_config()

	return __result


func load_export_config_from_node() -> Error:
	Admob.log_info("Loading export config from node!")

	var __result = OK

	var __admob_node: Admob = get_plugin_node(EditorInterface.get_edited_scene_root())
	if not __admob_node:
		var main_scene = load(ProjectSettings.get_setting("application/run/main_scene")).instantiate()
		__admob_node = get_plugin_node(main_scene)

	if __admob_node:
		is_real = __admob_node.is_real
		debug_application_id = __admob_node.ios_debug_application_id
		real_application_id = __admob_node.ios_real_application_id
		att_enabled = __admob_node.att_enabled
		att_text = __admob_node.att_text

		print_loaded_config()
	else:
		Admob.log_error("%s failed to find %s node!" % [PLUGIN_NAME, PLUGIN_NODE_TYPE_NAME])

	return __result


func print_loaded_config() -> void:
	super.print_loaded_config()
	Admob.log_info("... att_enabled: %s" % ("true" if att_enabled else "false"))
	Admob.log_info("... att_text: %s" % att_text)
