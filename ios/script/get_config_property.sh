#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$(realpath $SCRIPT_DIR/../config/config.properties)"
AS_ARRAY=false
QUOTE_ITEMS=false
SINGLE_LINE_ARRAY=false

# Parse options
while getopts "aqsf:" opt; do
	case "$opt" in
	a) AS_ARRAY=true ;;
	q) QUOTE_ITEMS=true ;;
	s) SINGLE_LINE_ARRAY=true ;;
	f) CONFIG_FILE="$OPTARG" ;;
	*) echo "Usage: $0 [-a] [-s] [-q] [-f <file>] <property_name>"; exit 1 ;;
	esac
done
shift $((OPTIND - 1))

# Validate property name
if [[ $# -lt 1 ]]; then
	echo "Usage: $0 [-a] [-s] [-q] [-f <file>] <property_name>"
	exit 1
fi

PROPERTY_NAME="$1"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
	echo "Error: Config file '$CONFIG_FILE' not found."
	exit 1
fi

# Extract property value (trim surrounding whitespace)
PROPERTY_VALUE=$(grep -E "^${PROPERTY_NAME}=" "$CONFIG_FILE" | cut -d'=' -f2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [[ -z "$PROPERTY_VALUE" ]]; then
	echo "Property '$PROPERTY_NAME' not found or empty in '$CONFIG_FILE'."
	exit 1
fi

# Output logic
if $AS_ARRAY; then
	IFS=',' read -r -a array <<< "$PROPERTY_VALUE"
	if $SINGLE_LINE_ARRAY; then
		if $QUOTE_ITEMS; then
			printf ' "%s"' "${array[@]}"
		else
			printf ' %s' "${array[@]}"
		fi
		echo	# newline
	else
		for item in "${array[@]}"; do
			if $QUOTE_ITEMS; then
				echo "\"$item\""
			else
				echo "$item"
			fi
		done
	fi
else
	if $QUOTE_ITEMS; then
		echo "\"$PROPERTY_VALUE\""
	else
		echo "$PROPERTY_VALUE"
	fi
fi
