---
title: Export
---

# <img src="./images/icon.png" width="20"> Export

Both `Android` and `iOS` exports require several configuration settings.

## <img src="./images/icon.png" width="18"> File-based Export Configuration

In order to enable file-based export configuration, an `android_export.cfg` or an `ios_export.cfg` file should be placed in the `addons/AdmobPlugin` directory with the file contents formatted as in the example below:

```ini
[General]
is_real = false

[Debug]
app_id = "ca-app-pub-3940256099942544~3347511713"

[Release]
app_id = "ca-app-pub-3940256099942544~3347511713"

[Mediation]
enabled_networks = ["applovin", "unity"]
```

The `ios_export.cfg` file supports the following additional properties, which are not relevant for Android.

```ini
[ATT]
att_enabled = true
att_text = "My ATT text."
```

!!! note

    The `is_real` and `app_id` configuration items are mandatory and if not found in the `export.cfg` file, then the plugin will fall back to node-based configuration.

## <img src="./images/icon.png" width="18"> Node-based Export Configuration

!!! note
    If `<platform>_export.cfg` file is not found for the target platform or file-based configuration fails, then the plugin will attempt to load node-based configuration.

During export, the plugin searches for an `Admob` node in the following order:

1. Search the selected scene that is open in the Godot Editor
2. If not found, then search for an `Admob` node in the scene that is configured as the project's main scene in the `Project Settings`
3. If still not found, then the plugin searches all scenes within the project.

!!! note
    If an `Admob` node is not found, then the app will fail due to missing AdMob application identifier.

    Therefore; make sure that at least one `Admob` node is present in any one of the scenes in your Godot project.
