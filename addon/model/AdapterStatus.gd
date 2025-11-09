#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdapterStatus extends RefCounted

const ADAPTER_CLASS_PROPERTY: String = "adapter_class"
const LATENCY_PROPERTY: String = "latency"
const INITIALIZATION_STATE_PROPERTY: String = "initialization_state"
const DESCRIPTION_PROPERTY: String = "description"

var _data: Dictionary


func _init(a_data: Dictionary):
	_data = a_data


func get_adapter_class() -> String:
	return _data[ADAPTER_CLASS_PROPERTY]


func get_latency() -> int:
	return _data[LATENCY_PROPERTY]


func get_initialization_state() -> String:
	return _data[INITIALIZATION_STATE_PROPERTY]


func get_description() -> String:
	return _data[DESCRIPTION_PROPERTY]
