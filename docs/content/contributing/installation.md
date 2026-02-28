---
title: Installation
---

# <img src="../images/icon.png" width="24"> Installation

## <img src="../images/icon.png" width="20"> Installing to Demo App

```bash
# Install both platforms
./script/build.sh -D

# Uninstall
./script/build.sh -d
```

## <img src="../images/icon.png" width="20"> Installing to Your Project

```bash
# Using install script
./script/install.sh -t /path/to/your/project -z /path/to/AdmobPlugin-*.zip

# Example
./script/install.sh -t ~/MyGame -z release/AdmobPlugin-Multi-v6.0.zip
```