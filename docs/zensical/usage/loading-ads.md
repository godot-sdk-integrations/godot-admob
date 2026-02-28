---
title: Loading ads
---

# <img src="../images/icon.png" width="18"> Loading and displaying ads

- initialize the plugin
	- call the `initialize()` method of the `Admob` node
	- wait for the `initialization_completed` signal

- use one or more of the following `load_*()` methods to load ads from the `Admob` node:
	- `load_banner_ad(ad_request: LoadAdRequest)`
	- `load_interstitial_ad(ad_request: LoadAdRequest)`
	- `load_rewarded_ad(ad_request: LoadAdRequest)`
	- `load_rewarded_interstitial_ad(ad_request: LoadAdRequest)`
	- `load_app_open_ad(ad_request: LoadAdRequest, auto_show_on_resume: boolean)`

- the `Admob` node will emit the following signals once ads have been loaded or failed to load:
	- `banner_ad_loaded(ad_info: AdInfo)`
	- `banner_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `interstitial_ad_loaded(ad_info: AdInfo)`
	- `interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `rewarded_ad_loaded(ad_info: AdInfo)`
	- `rewarded_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `rewarded_interstitial_ad_loaded(ad_info: AdInfo)`
	- `rewarded_interstitial_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`
	- `app_open_ad_loaded(ad_info: AdInfo)`
	- `app_open_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError)`

- once ads have been loaded, call corresponding `show_*()` method from the `Admob` node with the `ad_id` received:
	- `show_banner_ad(ad_id: String)`
	- `show_interstitial_ad(ad_id: String)`
	- `show_rewarded_ad(ad_id: String)`
	- `show_rewarded_interstitial_ad(ad_id: String)`
	- `show_app_open_ad()`