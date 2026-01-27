#
# © 2024-present https://github.com/cengiz-pz
#

class_name InitializationStatus extends RefCounted

var _data: Dictionary


func _init(a_data: Dictionary):
	if a_data == null:
		_data = {}
	else:
		_data = a_data


func get_network_tags() -> Array:
	return _data.keys()


func get_adapter_status(a_network_tag: String) -> AdapterStatus:
	return AdapterStatus.new(_data[a_network_tag]) if _data.has(a_network_tag) else null
