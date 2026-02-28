---
title: Android troubleshooting
---

# <img src="../images/icon.png" width="20"> Platform-Specific Notes

- Download Android export template and enable gradle build from export settings
- **Missing APP ID:**
- If your game crashes due to missing APP ID, then make sure that you
	- enter your Admob APP ID in the Admob node and pay attention to the Android Export section
	- or enter it in the `android_export.cfg` file as described in the [File-based Export](../export.md) section.
- **Troubleshooting:**
- Logs: `adb logcat | grep 'godot'` (Linux), `adb.exe logcat | select-string "godot"` (Windows)
- You may find the following resources helpful:
    - [Exporting for Android - Godot Docs](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
    - [Android Debug Bridge (ADB)](https://developer.android.com/tools/adb)
    - [Android Studio Debugging](https://developer.android.com/studio/debug)
    - [Android Developer Courses](https://developer.android.com/courses)