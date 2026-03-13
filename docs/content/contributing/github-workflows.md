---
title: GitHub Workflows
icon: fontawesome/brands/github
---

# GitHub Actions Workflows

This document describes each GitHub Actions workflow in `.github/workflows/`, covering what it does, when it runs, and which tools it relies on.

---

## Android Build (`android-build.yml`)

**Trigger:** Pull requests targeting `main` that touch any of the following paths:

- `common/config/**`
- `common/*.gradle.kts`
- `android/src/**`
- `android/*.gradle.kts`

**Runner:** `ubuntu-22.04`

**Purpose:**

Check that the Android plugin build completes successfully after each PR submission.

**What it does:**

Builds a debug Android AAR by invoking the `buildAndroidDebug` Gradle task from the `common` project directory. Before running the build, the workflow sets up the full toolchain: Node.js 22 (via `actions/setup-node`, or a manual tarball download when run locally with [act](https://github.com/nektos/act)), JDK 17 (Temurin distribution), and the Android SDK.

**Steps summary:**

| Step | Description |
|------|-------------|
| Checkout | Checks out the repository |
| Install Node (act) | Manual Node.js 22 install for local `act` runs |
| Setup Node (GitHub) | Standard Node.js 22 setup for GitHub-hosted runners |
| Set up JDK | Installs Temurin JDK 17 |
| Setup Android SDK | Installs the Android SDK via `android-actions/setup-android` |
| Build Android debug | Runs `./gradlew buildAndroidDebug` from `common/` |

---

## Android Code Style (`android-style.yml`)

**Trigger:** Pull requests targeting `main` that touch any of the following paths:

- `android/src/**/*.java`
- `android/src/**/*.kt`
- `android/src/**/*.xml`

**Runner:** `ubuntu-22.04`

**What it does:**

Enforces code style on all Android source files. Four independent checks are run in sequence:

1. **ktlint** — validates Kotlin source files against the project's ktlint rules.
2. **Checkstyle** — validates Java source files using the project's Checkstyle configuration at `.github/config/checkstyle.xml`. Checkstyle is downloaded directly from its GitHub releases at version 13.3.0.
3. **Prettier + XML plugin** — validates Android XML resource files using Prettier with the `@prettier/plugin-xml` plugin, configured by `.github/config/prettier.xml.json`.
4. **editorconfig-checker** — verifies that all `.java`, `.kt`, and `.xml` files comply with the repository's EditorConfig rules (final newlines, no trailing whitespace).

**Steps summary:**

| Step | Description |
|------|-------------|
| Checkout | Checks out the repository |
| Set up Java | Installs Temurin JDK 21 |
| Install ktlint | Uses the shared `.github/actions/install-ktlint` composite action |
| Run ktlint | Lints `android/src/**/*.kt` |
| Run Checkstyle | Downloads and runs Checkstyle 13.3.0 against `android/src` |
| Install Node | Uses the shared `.github/actions/install-node` composite action |
| Install Prettier and XML plugin | Runs `npm install --save-dev prettier @prettier/plugin-xml` |
| Check XML formatting | Runs `npx prettier --check` on `android/src/**/*.xml` |
| Install editorconfig-checker | Uses the shared `.github/actions/install-ec` composite action |
| Verify EditorConfig | Runs `editorconfig-checker` on all `.java`, `.kt`, and `.xml` files under `android/src` |

---

## Documentation (`docs.yml`)

**Trigger:** Pushes to `main` that touch any of the following paths:

- `docs/content/**`
- `.github/workflows/docs.yml`
- `docs/zensical.toml`

**Runner:** `ubuntu-22.04`

**Permissions:** `contents: read`, `pages: write`, `id-token: write`

**Concurrency:** Only one deployment runs at a time (`group: pages`); any in-progress run is cancelled when a new one starts.

**What it does:**

Builds and deploys the project's documentation site to GitHub Pages using the [Zensical](https://pypi.org/project/zensical/) static site generator. The built site is written to `docs/site/`, uploaded as a Pages artifact, and then deployed.

**Steps summary:**

| Step | Description |
|------|-------------|
| Configure Pages | Configures the GitHub Pages environment |
| Checkout | Checks out the repository |
| Setup Python | Installs Python 3.x |
| Install Dependencies | Upgrades pip and installs `zensical` |
| Build Documentation | Runs `zensical build --clean --config-file docs/zensical.toml` |
| Upload Pages | Uploads `docs/site` as a Pages artifact |
| Deploy Pages | Deploys the uploaded artifact to GitHub Pages |

---

## GDScript Code Style (`gdscript-style.yml`)

**Trigger:** Pull requests targeting `main` that touch any of the following paths:

- `addon/src/**/*.gd`
- `demo/**/*.gd`

**Runner:** `ubuntu-22.04`

**What it does:**

Validates GDScript formatting across the addon and demo directories using two tools:

1. **gdformat** (from [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit)) — checks formatting compliance with `--check` (dry run). The `.gdformatrc` configuration file is copied from `.github/config/` to the working directory before checking. Certain auto-generated files are excluded: `AdmobPlugin.gd` and `MediationNetwork.gd` in the addon, and `Main.gd` in the demo. Files under `demo/addons/` are also excluded.
2. **editorconfig-checker** — verifies final newlines and no trailing whitespace on all `.gd` files (same exclusion for `demo/addons/`).

**Steps summary:**

| Step | Description |
|------|-------------|
| Checkout | Checks out the repository |
| Install gdtoolkit | Creates a Python venv at `/opt/gdtoolkit`, installs `gdtoolkit`, adds it to `$GITHUB_PATH` |
| Verify Formatting | Copies `.gdformatrc`, runs `gdformat --check` on addon and demo `.gd` files |
| Install editorconfig-checker | Uses the shared `.github/actions/install-ec` composite action |
| Verify EditorConfig | Runs `editorconfig-checker` on all `.gd` files in addon and demo |

---

## Gradle Kotlin DSL Style (`gradle-kts-style.yml`)

**Trigger:** Pull requests targeting `main` that touch any of the following paths:

- `addon/*.gradle.kts`
- `android/*.gradle.kts`
- `common/*.gradle.kts`

**Runner:** `ubuntu-22.04`

**What it does:**

Validates formatting of all Gradle Kotlin DSL build files using two tools:

1. **ktlint 1.8.0** — checks all `*.gradle.kts` files at the root of `addon/`, `android/`, and `common/`.
2. **editorconfig-checker 3.6.1** — verifies final newlines and no trailing whitespace on the same set of files.

**Steps summary:**

| Step | Description |
|------|-------------|
| Checkout | Checks out the repository |
| Install Node | Uses the shared `.github/actions/install-node` composite action |
| Set up JDK | Installs Temurin JDK 17 |
| Install ktlint | Uses the shared `.github/actions/install-ktlint` composite action with version `1.8.0` |
| Run ktlint | Runs `ktlint` on all `*.gradle.kts` files in `addon/`, `android/`, and `common/` |
| Install editorconfig-checker | Uses the shared `.github/actions/install-ec` composite action with version `3.6.1` |
| Verify EditorConfig | Runs `editorconfig-checker` on the same set of files |

---

## iOS Build (`ios-build.yml`)

**Trigger:** Pull requests targeting `main` that touch any of the following paths:

- `common/config/**`
- `common/*.gradle.kts`
- `ios/src/**`
- `ios/config/**`
- `ios/*.gradle.kts`
- `ios/*.xcodeproj/**`

**Runner:** `macos-latest`

**Purpose:**

Check that the iOS plugin build completes successfully after each PR submission.

**What it does:**

Builds a debug iOS xcframework. The workflow first downloads the Godot engine sources and generates the Godot header files (both via dedicated Gradle tasks that delegate to `script/build_ios.sh`), then runs the full `buildiOSDebug` Gradle task. This task depends on GDScript generation, iOS config generation, SPM dependency management, and the Xcode build itself.

**Steps summary:**

| Step | Description |
|------|-------------|
| Checkout | Checks out the repository |
| Install Node | Uses the shared `.github/actions/install-node` composite action |
| Set up JDK | Installs Temurin JDK 17 |
| Download Godot | Runs `./gradlew downloadGodot` from `common/` |
| Generate Godot Headers | Runs `./gradlew generateGodotHeaders` from `common/` |
| Build iOS debug | Runs `./gradlew buildiOSDebug` from `common/` |

---

## iOS Code Style (`ios-style.yml`)

**Trigger:** Pull requests targeting `main` that touch any of the following paths:

- `ios/src/**/*.m`
- `ios/src/**/*.mm`
- `ios/src/**/*.h`
- `ios/src/**/*.swift`

**Runner:** `macos-latest`

**What it does:**

Validates code style on all iOS source files. Three independent checks are run:

1. **SwiftLint** — lints Swift files under `ios/src/` using the configuration at `.github/config/.swiftlint.yml`. Output is formatted for GitHub Actions annotations.
2. **clang-format** — performs a dry-run check (`--dry-run --Werror`) on all Objective-C and Objective-C++ files (`.m`, `.mm`, `.h`) using the style rules in `.github/config/.clang-format`.
3. **editorconfig-checker** — verifies final newlines and no trailing whitespace on all `.m`, `.mm`, `.h`, and `.swift` files (installed via Homebrew).

**Steps summary:**

| Step | Description |
|------|-------------|
| Checkout | Checks out the repository |
| Install SwiftLint | Runs `brew install swiftlint` |
| Install clang-format | Runs `brew install clang-format` |
| Run SwiftLint | Runs `swiftlint lint` on all `*.swift` files under `ios/src` |
| Run clang-format check | Runs `clang-format --dry-run --Werror` on all `.m`, `.mm`, `.h` files under `ios/src` |
| Install editorconfig-checker | Runs `brew install editorconfig-checker` |
| Verify EditorConfig | Runs `editorconfig-checker` on all iOS source files |

---

## Properties File Style (`properties-style.yml`)

**Trigger:** Pull requests targeting `main` that touch any of the following paths:

- `common/config/*.properties`
- `ios/config/*.properties`

**Runner:** `ubuntu-22.04`

**What it does:**

Validates that all `.properties` configuration files comply with the repository's EditorConfig rules (final newlines and no trailing whitespace) using **editorconfig-checker**.

**Steps summary:**

| Step | Description |
|------|-------------|
| Checkout | Checks out the repository |
| Install editorconfig-checker | Uses the shared `.github/actions/install-ec` composite action |
| Validate properties formatting | Runs `editorconfig-checker` on `common/config/*.properties` and `ios/config/*.properties` |

---

## Script Code Style (`script-style.yml`)

**Trigger:** Pull requests targeting `main` that touch any of the following paths:

- `script/**/*.sh`
- `script/**/*.rb`

**Runner:** `ubuntu-22.04`

**What it does:**

Validates coding style for all shell and Ruby scripts under `script/`. Three tools are run in sequence:

1. **ShellCheck** (v0.10.0) — static analysis for shell scripts (`*.sh`). Downloaded as a pre-built binary.
2. **RuboCop** (1.85.0) — lints Ruby scripts using the configuration at `.github/config/.rubocop.yml`.
3. **editorconfig-checker** — verifies final newlines and no trailing whitespace on all `.sh` and `.rb` files.

**Steps summary:**

| Step | Description |
|------|-------------|
| Checkout | Checks out the repository |
| Install Node | Uses the shared `.github/actions/install-node` composite action |
| Install ShellCheck | Downloads ShellCheck v0.10.0 binary and adds it to `$GITHUB_PATH` |
| Run ShellCheck | Runs `shellcheck` on all `*.sh` files under `script/` |
| Set up Ruby | Installs Ruby 3.2 via `ruby/setup-ruby` with bundler cache |
| Install RuboCop | Runs `gem install rubocop -v 1.85.0` |
| Run RuboCop | Runs `rubocop --config .github/config/.rubocop.yml script` |
| Install editorconfig-checker | Uses the shared `.github/actions/install-ec` composite action |
| Verify EditorConfig | Runs `editorconfig-checker` on all `.sh` and `.rb` files under `script/` |

---

## Shared Composite Actions

Several workflows reference local composite actions under `.github/actions/` rather than repeating installation steps inline. The following shared actions are used across multiple workflows:

| Action | Used by |
|--------|---------|
| `install-node` | `android-style`, `gradle-kts-style`, `ios-build`, `script-style` |
| `install-ktlint` | `android-style`, `gradle-kts-style` |
| `install-ec` | `android-style`, `gdscript-style`, `gradle-kts-style`, `properties-style`, `script-style` |
