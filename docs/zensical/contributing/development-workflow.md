---
title: Development workflow
---

# <img src="../images/icon.png" width="24"> Development Workflow

## Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/godot-sdk-integrations/godot-admob.git
   cd godot-admob
   ```

2. **Configure Android SDK:**
   ```bash
   echo "sdk.dir=/path/to/your/android-sdk" > common/local.properties
   ```

3. **First build:**
   ```bash
   # Android only
   ./script/build.sh -a -- -b

   # iOS only (macOS) - downloads Godot automatically
   ./script/build.sh -i -- -A
   ```

## Making Changes

1. **Edit source code:**
   - Android: `android/src/main/`
   - iOS: `ios/src/`
   - GDScript templates: `addon/src/`

2. **Build and test:**
   ```bash
   # Quick Android build
   ./script/build.sh -a -- -b

   # Install to demo app
   ./script/build.sh -D

   # Run demo in Godot to test
   cd demo
   godot project.godot
   ```

3. **Iterate:**
   - Make changes
   - Rebuild with `./script/build.sh -a -- -cb` or  `./script/build.sh -i -- -cb`
   - Test in demo app
   - Repeat until tests pass