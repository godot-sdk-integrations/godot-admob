---
title: App open ads
---

# <img src="../images/icon.png" width="20"> App Open Ads

App open ads are a special ad format intended for publishers wishing to monetize their app load screens. App open ads can be closed at any time, and are designed to be shown at startup or when your users bring your app to the foreground.

Set `auto_show_on_resume` to `true` in order to show app open ads when users resume (bring from background to foreground) your app. The app open ad should be loaded via the `load_app_open_ad()` method before it can be displayed at startup or upon resumption. Ideally, invoke the `load_app_open_ad()` method at startup and, if `auto_show_on_resume` is enabled, upon each `app_open_ad_impression` signal.
