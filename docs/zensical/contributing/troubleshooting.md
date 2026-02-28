---
title: Troubleshooting
---

# <img src="../images/icon.png" width="24"> Troubleshooting

## Common Build Issues

### Android

**Problem:** Gradle version mismatch
```bash
# Solution: Use Gradle wrapper
cd common
./gradlew --version
./gradlew clean build
```

**Problem:** Dependency resolution failures
```bash
# Solution: Clear Gradle cache
rm -rf ~/.gradle/caches/
./gradlew clean build --refresh-dependencies
```

### iOS

**Problem:** SPM package resolution fails
```bash
# Solution: Clear SPM cache and re-resolve
./script/build_ios.sh -pP
```

**Problem:** Header generation timeout
```bash
# Solution: Increase timeout
./script/build_ios.sh -H -t 120
```

**Problem:** Xcode build fails
```bash
# Solution: Clean derived data
rm -rf ios/build/DerivedData
./script/build_ios.sh -cb
```

**Problem:** Godot version mismatch when using a custom `godot.dir`
```
# The GODOT_VERSION file in the configured directory must match
# the godotVersion property in common/config/config.properties.
# Solution: remove and re-download Godot into the configured directory
./script/build_ios.sh -gG
```

**Problem:** Build cannot find Godot headers after setting `godot.dir`
```bash
# Verify the path is set correctly in common/local.properties:
#   godot.dir=/your/custom/path
# Then re-generate headers:
./script/build_ios.sh -H
```

**Problem:** "No such module" errors
```bash
# Solution: Ensure packages are added and resolved
./script/build_ios.sh -pP
```

## Getting Help

- Check existing [GitHub Issues](https://github.com/godot-sdk-integrations/godot-admob/issues)
- Check exısting [GitHub Discussions](https://github.com/godot-sdk-integrations/godot-admob/discussions)
- Review [Godot documentation](https://docs.godotengine.org/)
- See [Google AdMob documentation](https://developers.google.com/admob)