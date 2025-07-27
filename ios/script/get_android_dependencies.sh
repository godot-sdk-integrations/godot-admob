#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_DIR=$(realpath $SCRIPT_DIR/../../android)
TOML_FILE="$ANDROID_DIR/gradle/libs.versions.toml"

# Arrays to store versions
version_keys=()
version_values=()
library_versions=()

# --- Parse [versions] section ---
in_versions=0
while IFS= read -r line; do
	line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
	if [[ $line == "[versions]" ]]; then
		in_versions=1
		continue
	elif [[ $line == \[*] ]]; then
		in_versions=0
	fi

	if [[ $in_versions -eq 1 && $line =~ ^([a-zA-Z0-9_-]+)[[:space:]]*=[[:space:]]*\"([^\"]+)\" ]]; then
		version_keys+=("${BASH_REMATCH[1]}")
		version_values+=("${BASH_REMATCH[2]}")
	fi
done < "$TOML_FILE"

# Function to get version by key (since Bash 3.x has no associative arrays)
get_version() {
	local key="$1"
	for i in "${!version_keys[@]}"; do
		if [[ "${version_keys[$i]}" == "$key" ]]; then
			echo "${version_values[$i]}"
			return
		fi
	done
}

# --- Parse [libraries] section ---
in_libraries=0
while IFS= read -r line; do
	line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
	if [[ $line == "[libraries]" ]]; then
		in_libraries=1
		continue
	elif [[ $line == \[*] ]]; then
		in_libraries=0
	fi

	if [[ $in_libraries -eq 1 && $line =~ ^([a-zA-Z0-9_-]+)[[:space:]]*=.*version\.ref[[:space:]]*=[[:space:]]*\"([^\"]+)\" ]]; then
		lib="${BASH_REMATCH[1]}"
		version_key="${BASH_REMATCH[2]}"
		version="$(get_version "$version_key")"
		if [[ -n $version ]]; then
			library_versions+=("\"$lib:$version\"")
		fi
	fi
done < "$TOML_FILE"

# --- Output comma-separated, double-quoted values ---
IFS=','; echo "${library_versions[*]}"
