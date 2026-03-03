---
title: signals
icon: fontawesome/solid/signal
---

# <img src="../images/icon.png" width="20"> Signals

Register listeners for one or more signals of the `Admob` node. Signals are grouped below by ad type.

## Initialization

| Signal | Description |
|---|---|
| `initialization_completed(status_data: InitializationStatus)` | Emitted when the AdMob SDK has finished initializing. Check `status_data` for per-adapter readiness before loading ads. |

## Banner Ads

| Signal | Description |
|---|---|
| `banner_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)` | The banner ad was loaded successfully and is ready to be shown. |
| `banner_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)` | The banner ad failed to load. Inspect `error_data` for the error code and message. |
| `banner_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo)` | The banner ad was automatically refreshed with a new creative. |
| `banner_ad_impression(ad_info: AdInfo)` | The banner ad recorded an impression (became visible to the user). |
| `banner_ad_clicked(ad_info: AdInfo)` | The user tapped the banner ad. |
| `banner_ad_opened(ad_info: AdInfo)` | The banner ad opened an overlay or external browser in response to a tap. |
| `banner_ad_closed(ad_info: AdInfo)` | The overlay or browser opened by the banner ad was closed, and the user has returned to the app. |

## Interstitial Ads

| Signal | Description |
|---|---|
| `interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)` | The interstitial ad was loaded successfully and is ready to be shown. |
| `interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)` | The interstitial ad failed to load. Inspect `error_data` for the error code and message. |
| `interstitial_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo)` | The interstitial ad was refreshed with a new creative. |
| `interstitial_ad_impression(ad_info: AdInfo)` | The interstitial ad recorded an impression. |
| `interstitial_ad_clicked(ad_info: AdInfo)` | The user tapped the interstitial ad. |
| `interstitial_ad_showed_full_screen_content(ad_info: AdInfo)` | The interstitial ad was displayed and is covering the full screen. |
| `interstitial_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)` | The interstitial ad failed to display. Inspect `error_data` for the reason. |
| `interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo)` | The user dismissed the interstitial ad and has returned to the app. |

## Rewarded Ads

| Signal | Description |
|---|---|
| `rewarded_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)` | The rewarded ad was loaded successfully and is ready to be shown. |
| `rewarded_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)` | The rewarded ad failed to load. Inspect `error_data` for the error code and message. |
| `rewarded_ad_impression(ad_info: AdInfo)` | The rewarded ad recorded an impression. |
| `rewarded_ad_clicked(ad_info: AdInfo)` | The user tapped the rewarded ad. |
| `rewarded_ad_showed_full_screen_content(ad_info: AdInfo)` | The rewarded ad was displayed and is covering the full screen. |
| `rewarded_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)` | The rewarded ad failed to display. Inspect `error_data` for the reason. |
| `rewarded_ad_dismissed_full_screen_content(ad_info: AdInfo)` | The user dismissed the rewarded ad and has returned to the app. |
| `rewarded_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem)` | The user completed the reward condition. Use `reward_data` to retrieve the reward type and amount. Always grant the reward when this signal fires, regardless of whether the ad was dismissed. |

## Rewarded Interstitial Ads

| Signal | Description |
|---|---|
| `rewarded_interstitial_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)` | The rewarded interstitial ad was loaded successfully and is ready to be shown. |
| `rewarded_interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)` | The rewarded interstitial ad failed to load. Inspect `error_data` for the error code and message. |
| `rewarded_interstitial_ad_impression(ad_info: AdInfo)` | The rewarded interstitial ad recorded an impression. |
| `rewarded_interstitial_ad_clicked(ad_info: AdInfo)` | The user tapped the rewarded interstitial ad. |
| `rewarded_interstitial_ad_showed_full_screen_content(ad_info: AdInfo)` | The rewarded interstitial ad was displayed and is covering the full screen. |
| `rewarded_interstitial_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)` | The rewarded interstitial ad failed to display. Inspect `error_data` for the reason. |
| `rewarded_interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo)` | The user dismissed the rewarded interstitial ad and has returned to the app. |
| `rewarded_interstitial_ad_user_earned_reward(ad_info: AdInfo, reward_data: RewardItem)` | The user completed the reward condition. Use `reward_data` to retrieve the reward type and amount. Always grant the reward when this signal fires, regardless of whether the ad was dismissed. |

## App Open Ads

| Signal | Description |
|---|---|
| `app_open_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)` | The app open ad was loaded successfully and is ready to be shown. |
| `app_open_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)` | The app open ad failed to load. Inspect `error_data` for the error code and message. |
| `app_open_ad_impression(ad_info: AdInfo)` | The app open ad recorded an impression. |
| `app_open_ad_clicked(ad_info: AdInfo)` | The user tapped the app open ad. |
| `app_open_ad_showed_full_screen_content(ad_info: AdInfo)` | The app open ad was displayed and is covering the full screen. |
| `app_open_ad_failed_to_show_full_screen_content(ad_info: AdInfo, error_data: AdError)` | The app open ad failed to display. Inspect `error_data` for the reason. |
| `app_open_ad_dismissed_full_screen_content(ad_info: AdInfo)` | The user dismissed the app open ad and has returned to the app. |

## Native Ads

| Signal | Description |
|---|---|
| `native_ad_loaded(ad_info: AdInfo, response_info: ResponseInfo)` | The native ad was loaded successfully and its assets are ready to be rendered. |
| `native_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)` | The native ad failed to load. Inspect `error_data` for the error code and message. |
| `native_ad_impression(ad_info: AdInfo)` | The native ad recorded an impression. |
| `native_ad_size_measured(ad_info: AdInfo)` | The native ad's size has been measured and is available. Use this to adjust your UI layout if needed. |
| `native_ad_clicked(ad_info: AdInfo)` | The user tapped the native ad. |
| `native_ad_swipe_gesture_clicked(ad_info: AdInfo)` | The user interacted with the native ad via a swipe gesture. |
| `native_ad_opened(ad_info: AdInfo)` | The native ad opened an overlay or external browser in response to user interaction. |
| `native_ad_closed(ad_info: AdInfo)` | The overlay or browser opened by the native ad was closed, and the user has returned to the app. |

## Consent (UMP)

These signals are emitted during the User Messaging Platform (UMP) consent flow, used for GDPR and other privacy regulation compliance.

| Signal | Description |
|---|---|
| `consent_info_updated` | Consent information was successfully fetched and updated from Google's servers. |
| `consent_info_update_failed(error_data: FormError)` | The consent information request failed. Inspect `error_data` for the reason. |
| `consent_form_loaded` | The consent form was loaded and is ready to be displayed. |
| `consent_form_failed_to_load(error_data: FormError)` | The consent form failed to load. Inspect `error_data` for the reason. |
| `consent_form_dismissed(error_data: FormError)` | The user dismissed the consent form. If the user made a selection, `error_data` will be empty; otherwise it will contain the reason for dismissal. |
