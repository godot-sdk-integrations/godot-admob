#
# © 2024-present https://github.com/cengiz-pz
#

class_name ConsentRequestParameters extends RefCounted

enum DebugGeography {
	DEBUG_GEOGRAPHY_DISABLED = 0,
	DEBUG_GEOGRAPHY_EEA = 1,
	DEBUG_GEOGRAPHY_NOT_EEA = 2, # deprecated
	DEBUG_GEOGRAPHY_REGULATED_US_STATE = 3,
	DEBUG_GEOGRAPHY_OTHER = 4
}

const IS_REAL_PROPERTY: String = "is_real"
const TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY: String = "tag_for_under_age_of_consent"
const DEBUG_GEOGRAPHY_PROPERTY: String = "debug_geography"
const TEST_DEVICE_HASHED_IDS_PROPERTY: String = "test_device_hashed_ids"

var _data: Dictionary


func _init():
	_data = {}
	_data[TEST_DEVICE_HASHED_IDS_PROPERTY] = []


func set_is_real(a_value: bool) -> ConsentRequestParameters:
	_data[IS_REAL_PROPERTY] = a_value

	return self


func set_tag_for_under_age_of_consent(a_value: bool) -> ConsentRequestParameters:
	_data[TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY] = a_value

	return self


func set_debug_geography(a_value: DebugGeography) -> ConsentRequestParameters:
	_data[DEBUG_GEOGRAPHY_PROPERTY] = a_value

	return self


func add_test_device_hashed_id(a_value: String) -> ConsentRequestParameters:
	_data[TEST_DEVICE_HASHED_IDS_PROPERTY].append(a_value)

	return self


func get_device_ids() -> Array:
	return _data[TEST_DEVICE_HASHED_IDS_PROPERTY]


func get_raw_data() -> Dictionary:
	return _data
