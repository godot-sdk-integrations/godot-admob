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


func get_adapter_classes() -> Array:
	return _data.keys()


func get_adapter_status(a_adapter_class: String) -> AdapterStatus:
	return AdapterStatus.new(_data[a_adapter_class]) if _data.has(a_adapter_class) else null
