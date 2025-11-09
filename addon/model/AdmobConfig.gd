#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdmobConfig extends RefCounted

enum ContentRating {
	G,
	PG,
	T,
	MA
}

enum TagForChildDirectedTreatment {
	UNSPECIFIED = -1,
	FALSE = 0,
	TRUE = 1
}

enum TagForUnderAgeOfConsent {
	UNSPECIFIED = -1,
	FALSE = 0,
	TRUE = 1
}

enum PersonalizationState {
	DEFAULT = 0,
	ENABLED = 1,
	DISABLED = 2
}

const DATA_KEY_IS_REAL: String = "is_real"
const DATA_KEY_MAX_AD_CONTENT_RATING: String = "max_ad_content_rating"
const DATA_KEY_CHILD_DIRECTED_TREATMENT: String = "tag_for_child_directed_treatment"
const DATA_KEY_UNDER_AGE_OF_CONSENT: String = "tag_for_under_age_of_consent"
const DATA_KEY_FIRST_PARTY_ID_ENABLED: String = "first_party_id_enabled"
const DATA_KEY_PERSONALIZATION_STATE: String = "personalization_state"
const DATA_KEY_TEST_DEVICE_IDS = "test_device_ids"

var _data: Dictionary


func _init():
	_data = {
		DATA_KEY_TEST_DEVICE_IDS: []
	}


func set_is_real(a_value: bool) -> AdmobConfig:
	_data[DATA_KEY_IS_REAL] = a_value
	return self


func set_max_ad_content_rating(a_value: ContentRating) -> AdmobConfig:
	_data[DATA_KEY_MAX_AD_CONTENT_RATING] = ContentRating.keys()[a_value]
	return self


func set_child_directed_treatment(a_value: TagForChildDirectedTreatment) -> AdmobConfig:
	_data[DATA_KEY_CHILD_DIRECTED_TREATMENT] = a_value
	return self


func set_under_age_of_consent(a_value: TagForUnderAgeOfConsent) -> AdmobConfig:
	_data[DATA_KEY_UNDER_AGE_OF_CONSENT] = a_value
	return self


func set_first_party_id_enabled(a_value: bool) -> AdmobConfig:
	_data[DATA_KEY_FIRST_PARTY_ID_ENABLED] = a_value
	return self


func set_personalization_state(a_value: PersonalizationState) -> AdmobConfig:
	_data[DATA_KEY_PERSONALIZATION_STATE] = a_value
	return self


func set_test_device_ids(a_value: Array) -> AdmobConfig:
	if a_value == null:
		_data[DATA_KEY_TEST_DEVICE_IDS] = []
	else:
		_data[DATA_KEY_TEST_DEVICE_IDS] = a_value
	return self


func add_test_device_id(a_value: String) -> AdmobConfig:
	_data[DATA_KEY_TEST_DEVICE_IDS].append(a_value)
	return self


func get_raw_data() -> Dictionary:
	return _data
