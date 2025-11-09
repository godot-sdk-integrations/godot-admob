#
# © 2024-present https://github.com/cengiz-pz
#

class_name NetworkPrivacySettings extends RefCounted

const HAS_GDPR_CONSENT_PROPERTY = "has_gdpr_consent"
const IS_AGE_RESTRICTED_USER_PROPERTY = "is_age_restricted_user"
const HAS_CCPA_SALE_CONSENT_PROPERTY = "has_ccpa_sale_consent"
const ENABLED_NETWORKS_PROPERTY = "enabled_networks"

var _data: Dictionary


func _init() -> void:
	_data = {
		ENABLED_NETWORKS_PROPERTY: []
	}


func set_has_gdpr_consent(a_value: bool) -> NetworkPrivacySettings:
	_data[HAS_GDPR_CONSENT_PROPERTY] = a_value
	return self


func set_is_age_restricted_user(a_value: bool) -> NetworkPrivacySettings:
	_data[IS_AGE_RESTRICTED_USER_PROPERTY] = a_value
	return self


func set_has_ccpa_sale_consent(a_value: bool) -> NetworkPrivacySettings:
	_data[HAS_CCPA_SALE_CONSENT_PROPERTY] = a_value
	return self


func set_enabled_networks(a_value: Array[String]) -> NetworkPrivacySettings:
	if a_value == null:
		_data[ENABLED_NETWORKS_PROPERTY] = []
	else:
		_data[ENABLED_NETWORKS_PROPERTY] = a_value
	return self


func get_raw_data() -> Dictionary:
	return _data
