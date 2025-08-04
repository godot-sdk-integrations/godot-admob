#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdmobExportConfig extends RefCounted

const PLUGIN_NODE_TYPE_NAME = "@pluginNodeName@"
const PLUGIN_NAME: String = "@pluginName@"

const CONFIG_FILE_PATH: String = "res://addons/" + PLUGIN_NAME + "/export.cfg"

const CONFIG_FILE_SECTION_GENERAL: String = "General"
const CONFIG_FILE_SECTION_DEBUG: String = "Debug"
const CONFIG_FILE_SECTION_RELEASE: String = "Release"
const CONFIG_FILE_SECTION_ATT: String = "ATT"

const CONFIG_FILE_KEY_IS_REAL: String = "is_real"
const CONFIG_FILE_KEY_APP_ID: String = "app_id"
const CONFIG_FILE_KEY_ATT_ENABLED: String = "att_enabled"
const CONFIG_FILE_KEY_ATT_TEXT: String = "att_text"

var is_real: bool
var debug_application_id: String
var real_application_id: String
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
		debug_application_id = __admob_node.debug_application_id
		real_application_id = __admob_node.real_application_id
		att_enabled = __admob_node.att_enabled
		att_text = __admob_node.att_text

		print_loaded_config()
	else:
		Admob.log_error("%s failed to find %s node!" % [PLUGIN_NAME, PLUGIN_NODE_TYPE_NAME])

	return __result


func print_loaded_config() -> void:
	Admob.log_info("Loaded export configuration settings:")
	Admob.log_info("... is_real: %s" % ("true" if is_real else "false"))
	Admob.log_info("... debug_application_id: %s" % debug_application_id)
	Admob.log_info("... real_application_id: %s" % real_application_id)
	Admob.log_info("... att_enabled: %s" % ("true" if att_enabled else "false"))
	Admob.log_info("... att_text: %s" % att_text)


func get_plugin_node(a_node: Node) -> Admob:
	var __result: Admob

	if a_node is Admob:
		__result = a_node
	elif a_node.get_child_count() > 0:
		for __child in a_node.get_children():
			var __child_result = get_plugin_node(__child)
			if __child_result is Admob:
				__result = __child_result
				break

	return __result
