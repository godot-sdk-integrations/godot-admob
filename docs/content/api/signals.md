---
title: signals
---

# <img src="../images/icon.png" width="20"> Signals

 Register listeners for one or more of the following signals of the `Admob` node:

- `initialization_completed(status_data: InitializationStatus)`

- `banner_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
- `banner_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
- `banner_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo)`
- `banner_ad_clicked(ad_info: AdInfo)`
- `banner_ad_impression(ad_info: AdInfo)`
- `banner_ad_opened(ad_info: AdInfo)`
- `banner_ad_closed(ad_info: AdInfo)`

- `interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
- `interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
- `interstitial_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo)`
- `interstitial_ad_impression(ad_info: AdInfo)`
- `interstitial_ad_clicked(ad_info: AdInfo)`
- `interstitial_ad_showed_full_screen_content(ad_info: AdInfo)`
- `interstitial_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)`
- `interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo)`

- `rewarded_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
- `rewarded_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
- `rewarded_ad_impression(ad_info: AdInfo)`
- `rewarded_ad_clicked(ad_info: AdInfo)`
- `rewarded_ad_showed_full_screen_content(ad_info: AdInfo)`
- `rewarded_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)`
- `rewarded_ad_dismissed_full_screen_content(ad_info: AdInfo)`
- `rewarded_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem)`
- `rewarded_interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
- `rewarded_interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
- `rewarded_interstitial_ad_impression(ad_info: AdInfo)`
- `rewarded_interstitial_ad_clicked(ad_info: AdInfo)`
- `rewarded_interstitial_ad_showed_full_screen_content(ad_info: AdInfo)`
- `rewarded_interstitial_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)`
- `rewarded_interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo)`
- `rewarded_interstitial_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem)`

- `app_open_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
- `app_open_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
- `app_open_ad_impression(ad_info: AdInfo)`
- `app_open_ad_clicked(ad_info: AdInfo)`
- `app_open_ad_showed_full_screen_content(ad_info: AdInfo)`
- `app_open_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)`

- `native_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)`
- `native_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
- `native_ad_impression(ad_info: AdInfo)`
- `native_ad_size_measured(ad_info: AdInfo)`
- `native_ad_clicked(ad_info: AdInfo)`
- `native_ad_swipe_gesture_clicked(ad_info: AdInfo)`
- `native_ad_opened(ad_info: AdInfo)`
- `native_ad_closed(ad_info: AdInfo)`

- `app_open_ad_dismissed_full_screen_content(ad_info: AdInfo)`

- `consent_form_loaded`
- `consent_form_dismissed(error_data: FormError)`
- `consent_form_failed_to_load(error_data: FormError)`
- `consent_info_updated`
- `consent_info_update_failed(error_data: FormError)`
