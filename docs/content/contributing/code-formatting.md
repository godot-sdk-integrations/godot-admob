---
title: Code Formatting
icon: fontawesome/solid/code
---

# <img src="../images/icon.png" width="24"> Code Formatting

The project enforces consistent formatting across all source languages. Two aggregate tasks are available via the main build script:

```bash
# Verify all source code format compliance
./script/build.sh -v

# Fix all source code format issues
./script/build.sh -f
```

These delegate to the following per-language Gradle sub-tasks:

| Check task | Fix task | Language | Tool | Module |
|------------|----------|----------|------|--------|
| `checkGdscriptFormat` | `formatGdscriptSource` | GDScript | gdformat | addon |
| `checkJavaFormat` | `rewriteRun` | Java | Checkstyle / OpenRewrite | android |
| `checkXmlFormat` | `formatXml` | XML | Prettier | android |
| `checkObjCFormat` | `formatObjCSource` | ObjC / C++ | clang-format | ios |
| `checkSwiftFormat` | `formatSwiftSource` | Swift | swiftlint | ios |
| `checkKtsFormat` | `formatKtsSource` | Gradle KTS | ktlint | common |
| `checkBashScriptFormat` | `applyBashScriptFormat` | Bash | shellcheck | common |
| `checkEditorConfig` | _(n/a)_ | All files | editorconfig-checker | common |

Sub-tasks can also be run individually. For example, to check only GDScript formatting:

```bash
cd common
./gradlew :addon:checkGdscriptFormat
```

Sub-tasks that require external tools (`ktlint`, `shellcheck`, `editorconfig-checker`, `clang-format`, `swiftlint`, `gdformat`) will fail with a clear error if the tool is not found on `PATH`. See [Prerequisites](prerequisites.md) for installation instructions.
