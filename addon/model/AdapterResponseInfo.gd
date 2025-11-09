#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdapterResponseInfo extends RefCounted

const AD_ERROR_PROPERTY: String = "ad_error"
const AD_SOURCE_ID_PROPERTY: String = "ad_source_id"
const AD_SOURCE_INSTANCE_ID_PROPERTY: String = "ad_source_instance_id"
const AD_SOURCE_INSTANCE_NAME_PROPERTY: String = "ad_source_instance_name"
const AD_SOURCE_NAME_PROPERTY: String = "ad_source_name"
const ADAPTER_CLASS_NAME_PROPERTY: String = "adapter_class_name"
const NETWORK_TAG_PROPERTY: String = "network_tag"
const LATENCY_PROPERTY: String = "latency"

var _data: Dictionary


func _init(a_data: Dictionary):
	_data = a_data


func get_ad_error() -> AdError:
	return AdError.new(_data[AD_ERROR_PROPERTY]) \
			if _data.has(AD_ERROR_PROPERTY) else null


func get_ad_source_id() -> String:
	return _data[AD_SOURCE_ID_PROPERTY]


func get_ad_source_instance_id() -> String:
	return _data[AD_SOURCE_INSTANCE_ID_PROPERTY]


func get_ad_source_instance_name() -> String:
	return _data[AD_SOURCE_INSTANCE_NAME_PROPERTY]


func get_ad_source_name() -> String:
	return _data[AD_SOURCE_NAME_PROPERTY]


func get_adapter_class_name() -> String:
	return _data[ADAPTER_CLASS_NAME_PROPERTY]


func get_network_tag() -> String:
	return _data[NETWORK_TAG_PROPERTY]


func get_latency() -> int:
	return _data[LATENCY_PROPERTY]
