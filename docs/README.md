<div align="center">
	<img width="128" height="128" src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/demo/assets/admob-android.png">
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	<img width="128" height="128" src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/demo/assets/admob-ios.png">
</div>

---

<div align="center">
	<a href="https://github.com/godot-sdk-integrations/godot-admob">
	<img src="https://img.shields.io/github/stars/godot-sdk-integrations/godot-admob?style=social" />
	</a>
	<img src="https://img.shields.io/github/v/release/godot-sdk-integrations/godot-admob?label=Latest%20Release" />
	<img src="https://img.shields.io/github/downloads/godot-sdk-integrations/godot-admob/latest/total?label=Downloads" />
	<img src="https://img.shields.io/github/downloads/godot-sdk-integrations/godot-admob/total?label=Total%20Downloads" />
</div>

---

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Godot Admob Plugin

A Godot plugin that provides a unified GDScript interface for integrating **Google Mobile Ads SDK** on **Android** and **iOS**.

**Key Features:**
- **All ad formats** — Banner (fixed, adaptive, inline-adaptive, collapsible), Interstitial, Rewarded, Rewarded Interstitial, App Open, and Native ads
- **Rich signal coverage** — signals for load, impression, click, open, close, dismiss, reward, and failure events across all ad types
- **Node-based configuration** — all ad settings (position, size, content rating, volume, COPPA/TFUA tags, personalization state) configurable directly in the Godot Inspector
- **Ad caching** — built-in cache management with configurable cache sizes per ad type
- **Mediation support** — AdMob by default, with support for up to 15 additional ad networks
- **UMP consent flow** — built-in support for Google's User Messaging Platform for GDPR/privacy compliance
- **iOS tracking authorization** — handles ATT prompts and emits `tracking_authorization_granted` / `tracking_authorization_denied` signals
- **Flexible export configuration** — configure your AdMob app IDs via Inspector node or config files
- **Debug/production mode** — separate debug and real ad unit IDs; toggle with a single `is_real` flag

<a name="installation"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Installation

> **Before installing:** uninstall any previous version of this plugin. If installing both Android and iOS versions in the same project, ensure both use the same addon interface version.

**Via AssetLib (recommended)**
1. Search for `Admob` in the Godot Editor's AssetLib and click **Download**. (AssetLib Links: [Android](https://godotengine.org/asset-library/asset/2548), [iOS](https://godotengine.org/asset-library/asset/3178))
2. In the install dialog, keep the default install folder (project root) and **Ignore asset root** checked, then click **Install**.
3. Enable the plugin under **Project → Project Settings → Plugins**.

> If the installer warns about conflicting files when adding a second platform, you can safely ignore it — both platforms share the same addon code.

**Manually**
1. Download the release archive from [GitHub](https://github.com/godot-sdk-integrations/godot-admob/releases) and unzip it into your project's root directory.
2. Enable the plugin under **Project → Project Settings → Plugins**.

<a name="quick-start"></a>

## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> Quick Start

### 1. Add the Admob node

Add an `Admob` node to your main scene. In the Inspector:
- Enter your **Android/iOS application IDs** (debug and real).
- Enter your **ad unit IDs** for each format you plan to use. Debug IDs are pre-filled with Google's test IDs.
- Set `is_real = true` only when releasing to production. Leave it `false` during development.

### 2. Initialize

```gdscript
func _ready() -> void:
    $Admob.initialization_completed.connect(_on_admob_initialized)
    $Admob.initialize()

func _on_admob_initialized(status_data: InitializationStatus) -> void:
    print("AdMob ready: ", status_data)
    _load_ads()
```

### 3. Load an ad

```gdscript
func _load_ads() -> void:
    $Admob.banner_ad_loaded.connect(_on_banner_loaded)
    $Admob.banner_ad_failed_to_load.connect(_on_banner_failed)

    var request := LoadAdRequest.new()
    $Admob.load_banner_ad(request)
```

Available load methods: `load_banner_ad()`, `load_interstitial_ad()`, `load_rewarded_ad()`, `load_rewarded_interstitial_ad()`, `load_app_open_ad()`, `load_native_ad()`

### 4. Show the ad

Once the load signal fires, call the corresponding show method with the `ad_id` from the received `AdInfo`:

```gdscript
func _on_banner_loaded(ad_info: AdInfo, response_info: ResponseInfo) -> void:
    $Admob.show_banner_ad(ad_info.get_ad_id())
```

Available show methods: `show_banner_ad(ad_id)`, `show_interstitial_ad(ad_id)`, `show_rewarded_ad(ad_id)`, `show_rewarded_interstitial_ad(ad_id)`, `show_app_open_ad()`

### Key signals

| Signal | When it fires |
|---|---|
| `initialization_completed(status_data)` | SDK initialized |
| `*_ad_loaded(ad_info, response_info)` | Ad ready to show |
| `*_ad_failed_to_load(ad_info, error_data)` | Load failed |
| `*_ad_impression(ad_info)` | Ad became visible |
| `*_ad_clicked(ad_info)` | User tapped the ad |
| `*_ad_dismissed_full_screen_content(ad_info)` | Full-screen ad closed |
| `rewarded_ad_user_earned_reward(ad_info, reward_data)` | Reward granted |
| `consent_info_updated` / `consent_form_dismissed` | UMP consent flow events |
| `tracking_authorization_granted` / `tracking_authorization_denied` | iOS ATT result |

<a name="documentation"></a>

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Documentation

Explore the plugin documentation for a deep dive into features:

- https://godot-sdk-integrations.github.io/godot-admob

<a name="video-tutorials"></a>

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Video Tutorials

| Admob Plugin on Android | Consent Management with the Admob Plugin | Admob Plugin on Android |
| :---: | :---: | :---: |
| by [16BitDev](https://www.youtube.com/@16bitdev) | by [Code Artist](https://www.youtube.com/@codeartist1687) | by [Code Artist](https://www.youtube.com/@codeartist1687) |
| [<img src="https://img.youtube.com/vi/V9_Gpy0R3RE/0.jpg" width="280" alt="Admob Plugin on Android">](https://www.youtube.com/watch?v=V9_Gpy0R3RE) | [<img src="https://img.youtube.com/vi/MrLcPdoH-yU/0.jpg" width="280" alt="Consent Management with the Admob Plugin">](https://www.youtube.com/watch?v=MrLcPdoH-yU) | [<img src="https://img.youtube.com/vi/K13xFyOYySk/0.jpg" width="280" alt="Admob Plugin on Android">](https://www.youtube.com/watch?v=K13xFyOYySk) |

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> All Plugins

<a name="all-plugins"></a>

| | Plugin | Android | iOS | Latest Release | Downloads | Stars |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="20"> | [Admob](https://github.com/godot-sdk-integrations/godot-admob) | ✅ | ✅ | <a href="https://github.com/godot-sdk-integrations/godot-admob/releases"><img src="https://img.shields.io/github/v/release/godot-sdk-integrations/godot-admob?label=%20" /></a> | <img src="https://img.shields.io/github/downloads/godot-sdk-integrations/godot-admob/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-sdk-integrations/godot-admob/total?label=total" /> | <img src="https://img.shields.io/github/stars/godot-sdk-integrations/godot-admob?style=plastic&label=%20" /> |
| <img src="https://raw.githubusercontent.com/godot-mobile-plugins/godot-connection-state/main/addon/src/icon.png" width="20"> | [Connection State](https://github.com/godot-mobile-plugins/godot-connection-state) | ✅ | ✅ | <a href="https://github.com/godot-mobile-plugins/godot-connection-state/releases"><img src="https://img.shields.io/github/v/release/godot-mobile-plugins/godot-connection-state?label=%20" /></a> | <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-connection-state/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-connection-state/total?label=total" /> | <img src="https://img.shields.io/github/stars/godot-mobile-plugins/godot-connection-state?style=plastic&label=%20" /> |
| <img src="https://raw.githubusercontent.com/godot-mobile-plugins/godot-deeplink/main/addon/src/icon.png" width="20"> | [Deeplink](https://github.com/godot-mobile-plugins/godot-deeplink) | ✅ | ✅ | <a href="https://github.com/godot-mobile-plugins/godot-deeplink/releases"><img src="https://img.shields.io/github/v/release/godot-mobile-plugins/godot-deeplink?label=%20" /></a> | <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-deeplink/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-deeplink/total?label=total" /> | <img src="https://img.shields.io/github/stars/godot-mobile-plugins/godot-deeplink?style=plastic&label=%20" /> |
| <img src="https://raw.githubusercontent.com/godot-mobile-plugins/godot-firebase/main/addon/src/icon.png" width="20"> | [Firebase](https://github.com/godot-mobile-plugins/godot-firebase) | ✅ | ✅ | <!-- <a href="https://github.com/godot-mobile-plugins/godot-firebase/releases"><img src="https://img.shields.io/github/v/release/godot-mobile-plugins/godot-firebase?label=%20" /></a> --> | <!-- <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-firebase/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-firebase/total?label=%20" /> --> | <img src="https://img.shields.io/github/stars/godot-mobile-plugins/godot-firebase?style=plastic&label=%20" /> |
| <img src="https://raw.githubusercontent.com/godot-mobile-plugins/godot-inapp-review/main/addon/src/icon.png" width="20"> | [In-App Review](https://github.com/godot-mobile-plugins/godot-inapp-review) | ✅ | ✅ | <a href="https://github.com/godot-mobile-plugins/godot-inapp-review/releases"><img src="https://img.shields.io/github/v/release/godot-mobile-plugins/godot-inapp-review?label=%20" /></a> | <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-inapp-review/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-inapp-review/total?label=total" /> | <img src="https://img.shields.io/github/stars/godot-mobile-plugins/godot-inapp-review?style=plastic&label=%20" /> |
| <img src="https://raw.githubusercontent.com/godot-mobile-plugins/godot-native-camera/main/addon/src/icon.png" width="20"> | [Native Camera](https://github.com/godot-mobile-plugins/godot-native-camera) | ✅ | ✅ | <a href="https://github.com/godot-mobile-plugins/godot-native-camera/releases"><img src="https://img.shields.io/github/v/release/godot-mobile-plugins/godot-native-camera?label=%20" /></a> | <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-native-camera/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-native-camera/total?label=total" /> | <img src="https://img.shields.io/github/stars/godot-mobile-plugins/godot-native-camera?style=plastic&label=%20" /> |
| <img src="https://raw.githubusercontent.com/godot-mobile-plugins/godot-notification-scheduler/main/addon/src/icon.png" width="20"> | [Notification Scheduler](https://github.com/godot-mobile-plugins/godot-notification-scheduler) | ✅ | ✅ | <a href="https://github.com/godot-mobile-plugins/godot-notification-scheduler/releases"><img src="https://img.shields.io/github/v/release/godot-mobile-plugins/godot-notification-scheduler?label=%20" /></a> | <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-notification-scheduler/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-notification-scheduler/total?label=total" /> | <img src="https://img.shields.io/github/stars/godot-mobile-plugins/godot-notification-scheduler?style=plastic&label=%20" /> |
| <img src="https://raw.githubusercontent.com/godot-mobile-plugins/godot-oauth2/main/addon/src/icon.png" width="20"> | [OAuth 2.0](https://github.com/godot-mobile-plugins/godot-oauth2) | ✅ | ✅ | <a href="https://github.com/godot-mobile-plugins/godot-oauth2/releases"><img src="https://img.shields.io/github/v/release/godot-mobile-plugins/godot-oauth2?label=%20" /></a> | <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-oauth2/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-oauth2/total?label=total" /> | <img src="https://img.shields.io/github/stars/godot-mobile-plugins/godot-oauth2?style=plastic&label=%20" /> |
| <img src="https://raw.githubusercontent.com/godot-mobile-plugins/godot-qr/main/addon/src/icon.png" width="20"> | [QR](https://github.com/godot-mobile-plugins/godot-qr) | ✅ | ✅ | <a href="https://github.com/godot-mobile-plugins/godot-qr/releases"><img src="https://img.shields.io/github/v/release/godot-mobile-plugins/godot-qr?label=%20" /></a> | <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-qr/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-qr/total?label=total" /> | <img src="https://img.shields.io/github/stars/godot-mobile-plugins/godot-qr?style=plastic&label=%20" /> |
| <img src="https://raw.githubusercontent.com/godot-mobile-plugins/godot-share/main/addon/src/icon.png" width="20"> | [Share](https://github.com/godot-mobile-plugins/godot-share) | ✅ | ✅ | <a href="https://github.com/godot-mobile-plugins/godot-share/releases"><img src="https://img.shields.io/github/v/release/godot-mobile-plugins/godot-share?label=%20" /></a> | <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-share/latest/total?label=latest" /> <img src="https://img.shields.io/github/downloads/godot-mobile-plugins/godot-share/total?label=total" /> | <img src="https://img.shields.io/github/stars/godot-mobile-plugins/godot-share?style=plastic&label=%20" /> |

<a name="credits"></a>

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Credits

Developed by [Cengiz](https://github.com/cengiz-pz)

Based on [Godot Mobile Plugin Template](https://github.com/godot-mobile-plugins/godot-plugin-template)

Original repository: [Godot Admob Plugin](https://github.com/godot-sdk-integrations/godot-admob)

<a name="contributing"></a>

# <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="24"> Contributing

See [our guide](https://godot-sdk-integrations.github.io/godot-admob/contributing/) if you would like to contribute to this project.

# 💖 Support the Project

If this plugin has helped you, consider supporting its development! Every bit of support helps keep the plugin updated and bug-free.

| | Ways to Help | How to do it |
| :--- | :--- | :--- |
|✨⭐| **Spread the Word** | [Star this repo](https://github.com/godot-sdk-integrations/godot-admob/stargazers) to help others find it. |
|💡✨| **Give Feedback** | [Open an issue](https://github.com/godot-sdk-integrations/godot-admob/issues) or [suggest a feature](https://github.com/godot-sdk-integrations/godot-admob/issues/new). |
|🧩| **Contribute** | [Submit a PR](https://github.com/godot-sdk-integrations/godot-admob?tab=contributing-ov-file) to help improve the codebase. |
|❤️| **Buy a Coffee** | Support the maintainers on GitHub Sponsors or other platforms. |

## ⭐ Star History
[![Star History Chart](https://api.star-history.com/svg?repos=godot-sdk-integrations/godot-admob&type=Date)](https://star-history.com/#godot-sdk-integrations/godot-admob&Date)
