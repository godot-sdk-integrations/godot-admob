#
# © 2024-present https://github.com/cengiz-pz
#

class_name AdmobConfig extends RefCounted

enum ContentRating {
	G, ## G means "General Audiences" and is suitable for all ages, containing no objectionable material (minimal violence, no nudity or sex scenes, and no drug use).
	PG, ## PG stands for "Parental Guidance Suggested," meaning that some material may not be suitable for young children (may include themes, language, or mild violence).
	T, ## T means Teen, and indicates content suitable for ages 13 and older (can include violence, suggestive themes, crude humor, simulated gambling, and/or infrequent strong language).
	MA ## MA stands for "Mature Audience", signifying that the material is intended for adults (may include graphic violence, strong language, or explicit sexual activity).
}

enum TagForChildDirectedTreatment {
	UNSPECIFIED = -1, ## Means that you have not provided a specific instruction for your app's content to be treated as child-directed for COPPA purposes.
	FALSE = 0, ## Means you are indicating that your app's content is not child-directed for the purposes of the Children's Online Privacy Protection Act (COPPA).
	TRUE = 1 ## Tells ad networks to treat ad requests as if the content is directed towards children, which is important for complying with regulations like COPPA.
}

enum TagForUnderAgeOfConsent {
	UNSPECIFIED = -1, ## Means you have not provided any information on whether the user is under the age of consent, so the system does not apply any specific treatment for these users based on this tag alone.
	FALSE = 0, ## Indicates that you do not want the specific ad request to receive the special handling suitable for users under the age of consent in the EEA, the UK, and Switzerland.
	TRUE = 1 ## Indicates that you want the ad request to be handled in a manner suitable for users under the age of consent within the EEA, the UK, and Switzerland.
}

enum PersonalizationState {
	DEFAULT = 0, ## By default, the SDK will attempt to serve personalized ads based on the user's past behavior and interests.
	ENABLED = 1, ## Indicates that the Google Mobile Ads SDK is authorized to serve ads that are tailored to the user based on past activity and collected data. 
	DISABLED = 2 ## Means that ad requests are set to serve non-personalized ads (NPA) only. 
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
