#
# © 2026-present https://github.com/<<GitHubUsername>>
#

class_name GmpLogger extends Object

const PLUGIN_SINGLETON_NAME: String = "@pluginName@"


static func log_error(a_description: String) -> void:
	push_error("%s: %s" % [PLUGIN_SINGLETON_NAME, a_description])


static func log_warn(a_description: String) -> void:
	push_warning("%s: %s" % [PLUGIN_SINGLETON_NAME, a_description])


static func log_info(a_description: String) -> void:
	print_rich("[color=lime]%s: INFO: %s[/color]" % [PLUGIN_SINGLETON_NAME, a_description])
