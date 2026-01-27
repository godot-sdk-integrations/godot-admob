#
# © 2024-present https://github.com/cengiz-pz
#

class_name ResponseInfo extends RefCounted

const ADAPTER_RESPONSES_PROPERTY: String = "adapter_responses"
const LOADED_ADAPTER_RESPONSE_PROPERTY: String = "loaded_adapter_response"
const ADAPTER_CLASS_NAME_PROPERTY: String = "adapter_class_name"
const NETWORK_TAG_PROPERTY: String = "network_tag"
const RESPONSE_ID_PROPERTY: String = "response_id"

var _data: Dictionary


func _init(a_data: Dictionary):
	_data = a_data


func get_adapter_responses() -> Array[AdapterResponseInfo]:
	var __responses: Array[AdapterResponseInfo] = []

	for __response_dict in _data[ADAPTER_RESPONSES_PROPERTY]:
		__responses.append(AdapterResponseInfo.new(__response_dict))

	return __responses


func get_loaded_adapter_response() -> AdapterResponseInfo:
	return AdapterResponseInfo.new(_data[LOADED_ADAPTER_RESPONSE_PROPERTY]) \
			if _data.has(LOADED_ADAPTER_RESPONSE_PROPERTY) else null


func get_adapter_class_name() -> String:
	return _data[ADAPTER_CLASS_NAME_PROPERTY] \
			if _data.has(ADAPTER_CLASS_NAME_PROPERTY) else ""


func get_network_tag() -> String:
	return _data[NETWORK_TAG_PROPERTY] if _data.has(NETWORK_TAG_PROPERTY) else ""


func get_response_id() -> String:
	return _data[RESPONSE_ID_PROPERTY] if _data.has(RESPONSE_ID_PROPERTY) else ""
