---
title: Classes
---

# <img src="../images/icon.png" width="20"> Classes

## <img src="../images/icon.png" width="16"> AdapterResponseInfo

- Encapsulates adapter response data that is returned by the SDK for an ad request.
- Properties: `ad_error`, `ad_source_id`, `ad_source_instance_id`, `ad_source_instance_name`, `ad_source_name`, `adapter_class_name`, `network_tag`, `latency`

## <img src="../images/icon.png" width="16"> AdapterStatus
- Encapsulates adapter status data that is returned by the SDK after initialization or status request.
- Properties: `adapter_class`, `latency`, `initialization_state`, `description`

## <img src="../images/icon.png" width="16"> AdError

- Encapsulates error data that is returned by the SDK if an ad fails to display or in other scenarios.
- Properties: `code`, `domain`, `message`, `cause`

## <img src="../images/icon.png" width="16"> AdmobAdSize

- Encapsulates ad size data returned by the SDK.
- Properties: `width`, `height`

## <img src="../images/icon.png" width="16"> AdmobConfig

- Encapsulates general configuration data that is applied to all ad requests.
- Properties: `is_real`, `max_ad_content_rating`, `tag_for_child_directed_treatment`, `tag_for_under_age_of_consent`, `first_party_id_enabled`, `personalization_state`, `test_device_ids`

## <img src="../images/icon.png" width="16"> AdmobSettings

- Encapsulates global settings that are applied to all ads loaded after the values have been set.
- Properties:
	- `ad_volume`: Global volume level for all ads
	- `ads_muted`: Whether or not ads are muted
	- `apply_at_startup`: Whether or not the global settings will be reapplied at startup

## <img src="../images/icon.png" width="16"> ConsentInformation
- Contains consent status values.

## <img src="../images/icon.png" width="16"> ConsentRequestParameters

- Encapsulates consent request data that is sent when requesting users' consent for data collection.
- Properties: `is_real`, `tag_for_under_age_of_consent`, `debug_geography`, `test_device_hashed_ids`

## <img src="../images/icon.png" width="16"> FormError

- Encapsulates error data that is returned by the SDK if an ad fails to load or display a consent form.
- Properties: `code`, `message`

## <img src="../images/icon.png" width="16"> InitializationStatus
- Contains a dictionary of `AdapterStatus` objects.

## <img src="../images/icon.png" width="16"> LoadAdError

- Encapsulates error data that is returned by the SDK if an ad fails to load.
- Properties: `code`, `domain`, `message`, `cause`, `response_info`

## <img src="../images/icon.png" width="16"> LoadAdRequest

- Encapsulates data that defines a request for an ad.
- Properties: `ad_unit_id`, `request_agent`, `ad_size`, `ad_position`, `keywords`, `user_id`, `collapsible_position`, `anchor_to_safe_area`, `custom_data`, `network_extras`

## <img src="../images/icon.png" width="16"> MediationNetwork

- Encapsulates data that defines an ad mediation network.
- Properties: `flag`, `tag`, `dependencies`, `maven_repo`, `pod`, `pod_version`, `sk_ad_network_ids`

## <img src="../images/icon.png" width="16"> NetworkExtras

- Encapsulates data that facilitates setting of extra properties required by an ad mediation network.
- Properties: `network_tag`, `extras`

### <img src="../images/icon.png" width="16"> NetworkPrivacySettings
- Encapsulates data that represents a user's privacy settings.
- Properties: `has_gdpr_consent`, `is_age_restricted_user`, `has_ccpa_sale_consent`, `enabled_networks`

## <img src="../images/icon.png" width="16"> ResponseInfo

- Encapsulates data that defines the response for an ad request.
- Properties: `adapter_responses`, `loaded_adapter_response`, `adapter_class_name`, `network_tag`, `response_id`

## <img src="../images/icon.png" width="16"> RewardItem

- Encapsulates data that defines the received reward from a rewarded ad.
- Properties: `amount`, `type`