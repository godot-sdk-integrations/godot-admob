#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdmobExportConfig extends RefCounted

const PLUGIN_NODE_TYPE_NAME = "@pluginNodeName@"
const PLUGIN_NAME: String = "@pluginName@"

const CONFIG_FILE_SECTION_GENERAL: String = "General"
const CONFIG_FILE_SECTION_DEBUG: String = "Debug"
const CONFIG_FILE_SECTION_RELEASE: String = "Release"

const CONFIG_FILE_KEY_IS_REAL: String = "is_real"
const CONFIG_FILE_KEY_APP_ID: String = "app_id"

var is_real: bool
var debug_application_id: String
var real_application_id: String


func export_config_file_exists() -> bool:
	return false


func load_export_config_from_file() -> Error:
	return Error.OK


func load_export_config_from_node() -> Error:
	return Error.OK


func print_loaded_config() -> void:
	Admob.log_info("Loaded export configuration settings:")
	Admob.log_info("... is_real: %s" % ("true" if is_real else "false"))
	Admob.log_info("... debug_application_id: %s" % debug_application_id)
	Admob.log_info("... real_application_id: %s" % real_application_id)


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
