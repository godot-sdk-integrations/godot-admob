---
title: Installation
---

# <img src="../images/icon.png" width="20"> Installation

_Before installing this plugin, make sure to uninstall any previous versions of the same plugin._

_If installing both Android and iOS versions of the plugin in the same project, make sure that both versions use the same addon interface version._

There are 2 ways to install the `Admob` plugin into your project:

- Through the Godot Editor's AssetLib
- Manually by downloading archives from [GitHub](https://github.com/godot-sdk-integrations/godot-admob/releases)

## <img src="../images/icon.png" width="18"> Installing via AssetLib

- Search for and select the `Admob` plugin in Godot Editor
- Click the `Download` button
- On the installation dialog:
    - Keep `Change Install Folder` pointing to your project's root directory
    - Keep `Ignore asset root` checkbox checked
    - Click `Install` button
- Enable the plugin via the `Plugins` tab of `Project -> Project Settings...` menu in Godot Editor

## <img src="../images/icon.png" width="18"> Installing manually

- Download the release archive from GitHub
- Unzip the release archive
- Copy it to your Godot project's root directory
- Enable the plugin via the `Plugins` tab of `Project -> Project Settings...` menu in Godot Editor

!!! note "Installing both Android and iOS versions of the plugin in the same project"

    When installing via AssetLib, the installer may display a warning that states
    "_[x number of]_ files conflict with your project and won't be installed."
    You can ignore this warning since both versions use the same addon code.