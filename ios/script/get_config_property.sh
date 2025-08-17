#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AS_ARRAY=false
QUOTE_ITEMS=false
SINGLE_LINE_ARRAY=false

# Function to print usage information
print_usage() {
	echo "Usage: $0 [-a] [-s] [-q] [-h] -f <file> <property_name>"
	echo "Options:"
	echo "  -a          Treat property value as a comma-separated array"
	echo "  -s          Output array items on a single line"
	echo "  -q          Quote output items"
	echo "  -h          Show this help message and exit"
	echo "  -f <file>   Specify the config file (required)"
}

# Parse options
while getopts "aqshf:" opt; do
	case "$opt" in
	a) AS_ARRAY=true ;;
	q) QUOTE_ITEMS=true ;;
	s) SINGLE_LINE_ARRAY=true ;;
	h) print_usage; exit 0 ;;
	f) CONFIG_FILE="$OPTARG" ;;
	*) print_usage; exit 1 ;;
	esac
done
shift $((OPTIND - 1))

# Validate config file option
if [[ -z "$CONFIG_FILE" ]]; then
	echo "Error: Config file must be specified with -f option."
	print_usage
	exit 1
fi

# Resolve absolute path for config file
CONFIG_FILE="$(realpath "$CONFIG_FILE")"

# Validate property name
if [[ $# -lt 1 ]]; then
	print_usage
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
	echo ""	# property was empty or not found in the config file
else
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
fi
