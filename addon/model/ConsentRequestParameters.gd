#
# © 2024-present https://github.com/cengiz-pz
#

class_name ConsentRequestParameters extends RefCounted

enum DebugGeography {
	NOT_SET = -1, ## Don't specify location. (Actual location will be used.)
	DISABLED = 0, ## Use actual location.
	EEA = 1, ## Use European Economic Area.
	NOT_EEA = 2, ## Deprecated.
	REGULATED_US_STATE = 3, ## Use a regulated state of USA. (ie. California)
	OTHER = 4 ## Use any non-regulated location.
}

const IS_REAL_PROPERTY: String = "is_real"
const TAG_FOR_UNDER_AGE_OF_CONSENT_PROPERTY: String = "tag_for_under_age_of_consent"
const DEBUG_GEOGRAPHY_PROPERTY: String = "debug_geography"
const TEST_DEVICE_HASHED_IDS_PROPERTY: String = "test_device_hashed_ids"

var _data: Dictionary


func _init():
	_data = {
		TEST_DEVICE_HASHED_IDS_PROPERTY: []
	}


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
