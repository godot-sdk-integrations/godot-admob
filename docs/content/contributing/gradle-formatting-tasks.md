# Gradle Formatting Tasks

This document describes the `checkFormat` and `applyFormat` aggregate Gradle tasks, all tasks they depend on, and the prerequisite tools that must be installed on the system before those tasks can execute successfully.

---

## Overview

Two top-level aggregate tasks orchestrate formatting across the entire repository:

| Task | Group | Description |
|------|-------|-------------|
| `checkFormat` | — | Validates formatting in all source code (dry run, no files modified) |
| `applyFormat` | — | Applies formatting to all source code in-place |

Both tasks are registered in `common/build.gradle.kts` and delegate to a set of language-specific subtasks spread across the `common`, `android`, and `addon` subprojects.

---

## `checkFormat`

```
./gradlew checkFormat
```

Runs all format-check subtasks. Fails if any file violates the expected style; no files are modified.

**Dependencies:**

| Subtask | Subproject | Language / File Type |
|---------|------------|----------------------|
| `:android:rewriteDryRun` | `android` | Java & Kotlin (OpenRewrite) |
| `:android:checkXmlFormat` | `android` | XML (Prettier) |
| `checkIosFormat` | `common` | Objective-C / Objective-C++ (clang-format) |
| `checkKtsFormat` | `common` | Gradle Kotlin DSL (ktlint) |
| `:addon:checkGdscriptFormat` | `addon` | GDScript (gdformat) |

---

## `applyFormat`

```
./gradlew applyFormat
```

Runs all format-apply subtasks and rewrites files in-place. Should be run locally before committing, or to resolve formatting failures reported by `checkFormat`.

**Dependencies:**

| Subtask | Subproject | Language / File Type |
|---------|------------|----------------------|
| `:android:rewriteRun` | `android` | Java & Kotlin (OpenRewrite) |
| `:android:formatXml` | `android` | XML (Prettier) |
| `formatIosSource` | `common` | Objective-C / Objective-C++ (clang-format) |
| `formatKtsSource` | `common` | Gradle Kotlin DSL (ktlint) |
| `:addon:formatGdscriptSource` | `addon` | GDScript (gdformat) |

---

## Subtask Reference

### `checkIosFormat` — iOS Source Format Check

**Defined in:** `common/build.gradle.kts`  
**Type:** `Exec`  
**Group:** `formatting`

Performs a dry-run clang-format check on all Objective-C and Objective-C++ source files under `ios/src/`. The task fails if any file's formatting deviates from the rules defined in `.github/config/.clang-format`. No files are written.

**Source files:** `ios/src/**/*.mm`, `ios/src/**/*.m`, `ios/src/**/*.h`

**Command executed:**
```
clang-format --style=file:../../.github/config/.clang-format --dry-run --Werror <files…>
```

**Working directory:** `ios/src/`

**Fails if:** No source files are found, or any file is not correctly formatted.

---

### `formatIosSource` — iOS Source Format Apply

**Defined in:** `common/build.gradle.kts`  
**Type:** `Exec`  
**Group:** `formatting`

Formats all Objective-C and Objective-C++ source files under `ios/src/` in-place using clang-format.

**Source files:** `ios/src/**/*.mm`, `ios/src/**/*.m`, `ios/src/**/*.h`

**Command executed:**
```
clang-format --style=file:../../.github/config/.clang-format -i <files…>
```

**Working directory:** `ios/src/`

**Fails if:** No source files are found.

---

### `checkKtsFormat` — Gradle KTS Format Check

**Defined in:** `common/build.gradle.kts`  
**Type:** `Exec`  
**Group:** `formatting`

Performs a dry-run ktlint check on all `*.gradle.kts` files at the root of the `addon/`, `android/`, and `common/` directories. Fails if any file violates ktlint's rules. No files are written.

**Source files:** `addon/*.gradle.kts`, `android/*.gradle.kts`, `common/*.gradle.kts`

**Command executed:**
```
ktlint addon/<files…> android/<files…> common/<files…>
```

**Working directory:** Repository root (`$rootDir/..`)

**Fails if:** No `.gradle.kts` files are found in any of the three directories, or any file is not correctly formatted.

---

### `formatKtsSource` — Gradle KTS Format Apply

**Defined in:** `common/build.gradle.kts`  
**Type:** `Exec`  
**Group:** `formatting`

Formats all `*.gradle.kts` files at the root of `addon/`, `android/`, and `common/` in-place using ktlint.

**Source files:** `addon/*.gradle.kts`, `android/*.gradle.kts`, `common/*.gradle.kts`

**Command executed:**
```
ktlint --format addon/<files…> android/<files…> common/<files…>
```

**Working directory:** Repository root (`$rootDir/..`)

**Fails if:** No `.gradle.kts` files are found.

---

### `checkGdscriptFormat` — GDScript Format Check

**Defined in:** `addon/build.gradle.kts`  
**Type:** `Exec`  
**Group:** `formatting`

Performs a dry-run gdformat check on GDScript source files under `addon/src/`. The task temporarily copies `.github/config/.gdformatrc` into the source directory before running, and removes it again when done (in `doLast`). Fails if any file's formatting deviates from the expected style. No files are written.

**Source files:** `addon/src/**/*.gd`

**Excluded files:**
- `**/AdmobPlugin.gd`
- `**/MediationNetwork.gd`

**Command executed:**
```
gdformat --check <files…>
```

**Working directory:** `addon/src/` (the `templateDir` property)

**Fails if:** No source files are found after exclusions, or any file is not correctly formatted.

**Config file lifecycle:**
1. `doFirst`: Copies `.github/config/.gdformatrc` → `addon/src/.gdformatrc`
2. Task executes
3. `doLast`: Deletes `addon/src/.gdformatrc`

---

### `formatGdscriptSource` — GDScript Format Apply

**Defined in:** `addon/build.gradle.kts`  
**Type:** `Exec`  
**Group:** `formatting`

Formats GDScript source files under `addon/src/` in-place using gdformat. Applies the same exclusions and `.gdformatrc` lifecycle as `checkGdscriptFormat`.

**Source files:** `addon/src/**/*.gd` (same exclusions as `checkGdscriptFormat`)

**Command executed:**
```
gdformat <files…>
```

**Working directory:** `addon/src/`

**Fails if:** No source files are found after exclusions.

**Config file lifecycle:** Same as `checkGdscriptFormat` — `.gdformatrc` is copied before and removed after execution.

---

### `:android:rewriteDryRun` — Android OpenRewrite Dry Run

**Defined in:** `android/build.gradle.kts` (not shown)  
**Plugin:** `org.openrewrite.rewrite` (applied via `libs.plugins.openrewrite`)

Runs OpenRewrite recipes against Java and Kotlin files under `android/src/` in dry-run mode. Reports which files would be changed without writing any changes to disk.

---

### `:android:rewriteRun` — Android OpenRewrite Apply

**Defined in:** `android/build.gradle.kts` (not shown)  
**Plugin:** `org.openrewrite.rewrite`

Runs OpenRewrite recipes against Java and Kotlin files under `android/src/` and writes the results to disk.

---

### `:android:checkXmlFormat` — Android XML Format Check

**Defined in:** `android/build.gradle.kts` (not shown)  
**Tool:** Prettier + `@prettier/plugin-xml`

Validates Android XML resource files under `android/src/` using Prettier with the XML plugin, configured by `.github/config/prettier.xml.json`. No files are written.

---

### `:android:formatXml` — Android XML Format Apply

**Defined in:** `android/build.gradle.kts` (not shown)  
**Tool:** Prettier + `@prettier/plugin-xml`

Formats Android XML resource files under `android/src/` in-place using Prettier.

---

## Prerequisites

The following tools must be installed and available on `PATH` before the `Exec` tasks can execute successfully.

### clang-format

**Required by:** `checkIosFormat`, `formatIosSource`  
**Configuration:** `.github/config/.clang-format`

**macOS (Homebrew):**
```sh
brew install clang-format
```

**Ubuntu/Debian:**
```sh
sudo apt-get install clang-format
```

**Verify:**
```sh
clang-format --version
```

Ensure the installed version is compatible with the style options used in `.github/config/.clang-format`. The iOS style workflow on GitHub uses the version available in the default Homebrew tap.

---

### ktlint

**Required by:** `checkKtsFormat`, `formatKtsSource`  
**Version used in CI:** 1.8.0 (pinned in `gradle-kts-style.yml`)

ktlint is installed by the shared `.github/actions/install-ktlint` composite action in CI. For local use, the recommended approach is to download the binary directly:

```sh
curl -sSLO https://github.com/pinterest/ktlint/releases/download/1.8.0/ktlint
chmod +x ktlint
sudo mv ktlint /usr/local/bin/
```

**Verify:**
```sh
ktlint --version
```

---

### gdformat (gdtoolkit)

**Required by:** `checkGdscriptFormat`, `formatGdscriptSource`  
**Package:** `gdtoolkit` (Python package providing `gdformat` and `gdlint`)

**Install via pip (system):**
```sh
pip install gdtoolkit
```

**Install via virtualenv (recommended, mirrors CI):**
```sh
python3 -m venv /opt/gdtoolkit
/opt/gdtoolkit/bin/pip install gdtoolkit
# Add to PATH:
export PATH="/opt/gdtoolkit/bin:$PATH"
```

**Verify:**
```sh
gdformat --version
```

The `.gdformatrc` configuration file is managed automatically by the Gradle tasks — it is copied from `.github/config/.gdformatrc` to the working directory before each run and removed afterwards. It does not need to be placed manually.

---

### Node.js + Prettier + @prettier/plugin-xml

**Required by:** `:android:checkXmlFormat`, `:android:formatXml`  
**Prettier config:** `.github/config/prettier.xml.json`

Node.js must be available for Prettier to run. The android subproject's Gradle build uses the [gradle-node-plugin](https://github.com/node-gradle/gradle-node-plugin) to manage a project-local Node.js installation, so a system-wide Node.js installation may not be strictly required when running through Gradle. However, if the Android XML formatting tasks invoke `npx` directly, Node.js 22+ must be on `PATH`.

**macOS (Homebrew):**
```sh
brew install node
```

**Ubuntu (via NodeSource):**
```sh
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Install Prettier locally within the project:**
```sh
npm install --save-dev prettier @prettier/plugin-xml
```

**Verify:**
```sh
node --version
npx prettier --version
```

---

### OpenRewrite Gradle Plugin

**Required by:** `:android:rewriteDryRun`, `:android:rewriteRun`  
**Plugin ID:** `org.openrewrite.rewrite` (referenced as `libs.plugins.openrewrite`)

This is a Gradle plugin dependency declared in the version catalog and applied to the `android` subproject. No separate system installation is required — Gradle resolves it from Maven Central automatically during the build. Ensure network access is available on first use, or that the Gradle dependency cache is populated.

---

## Configuration Files

| File | Used by | Purpose |
|------|---------|---------|
| `.github/config/.clang-format` | `checkIosFormat`, `formatIosSource` | clang-format style rules for iOS Objective-C/C++ files |
| `.github/config/.gdformatrc` | `checkGdscriptFormat`, `formatGdscriptSource` | gdformat configuration for GDScript files |
| `.github/config/prettier.xml.json` | `:android:checkXmlFormat`, `:android:formatXml` | Prettier configuration for Android XML files |

---

## Task Dependency Graph

```
checkFormat
├── :android:rewriteDryRun        (Java/Kotlin — OpenRewrite)
├── :android:checkXmlFormat       (XML — Prettier)
├── checkIosFormat                (ObjC/ObjC++ — clang-format)
├── checkKtsFormat                (*.gradle.kts — ktlint)
└── :addon:checkGdscriptFormat    (GDScript — gdformat)

applyFormat
├── :android:rewriteRun           (Java/Kotlin — OpenRewrite)
├── :android:formatXml            (XML — Prettier)
├── formatIosSource               (ObjC/ObjC++ — clang-format)
├── formatKtsSource               (*.gradle.kts — ktlint)
└── :addon:formatGdscriptSource   (GDScript — gdformat)
```
