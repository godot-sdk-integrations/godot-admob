---
title: User consent
---

# <img src="../images/icon.png" width="20"> User Consent

The consent status indicates that the user has been presented with the consent form and has submitted a choice (either consent or withhold consent), making the consent information available for use. It does not indicate that the user has specifically consented to personalized ads — only that consent information has been obtained. Therefore, the plugin will return a status of "OBTAINED" even when the user selects "Do Not Consent" on the consent form.

The UMP SDK handles propagation of the user's actual consent choice to the Google Mobile Ads SDK automatically. Ad requests made after consent is obtained will respect the user's selection (e.g., non-personalized ads if they did not consent).

## <img src="../images/icon.png" width="18"> User Consent Methods

- `get_consent_status()` - Returns a consent status value defined in `ConsentInformation.gd`
- `update_consent_info(params: ConsentRequestParameters)` - To be called if `get_consent_status()` returns status UNKNOWN.
- `reset_consent_info()` - To be used only when testing and debugging your application.
- `is_consent_form_available()`
- `load_consent_form()` - To be called if `get_consent_status()` returns status REQUIRED and `is_consent_form_available()` returns `false`.
- `show_consent_form()` - To be called after `consent_form_loaded` signal has been emitted or `is_consent_form_available()` returns `true`.


## <img src="https://raw.githubusercontent.com/godot-sdk-integrations/godot-admob/main/addon/src/icon.png" width="18"> Testing User Consent Logic

In order to test user consent logic for your app, you need to add your test device's hashed identifier to the `test_device_hashed_ids` array of your `Admob` node (or set it programmatically). If you don't know your test device hashed identifier, then run your app with `is_real` set to `false` and look for a log entry such as the following that is logged on iOS.

```
<UMP SDK> To enable debug mode for this device, set: UMPDebugSettings.testDeviceIdentifiers = @[ @"76E885D5-7ACF-4EA8-9B2D-CD8DABB21A1B" ];
```