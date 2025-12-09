#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

PROPERTY_NAME="$1"
FILE="$2"

if [ -z "$PROPERTY_NAME" ] || [ -z "$FILE" ]; then
	echo "Usage: $0 <property_name> <path_to_config.gradle.kts>"
	exit 1
fi

if [ ! -f "$FILE" ]; then
	echo "File not found: $FILE"
	exit 1
fi

# Extract the extra.apply block contents
in_block=0
block=""
while IFS= read -r line; do
	if echo "$line" | grep -q 'extra[[:space:]]*\.[[:space:]]*apply[[:space:]]*{' ; then
		in_block=1
		continue
	fi
	if [ $in_block -eq 1 ]; then
		if echo "$line" | grep -q '^}' ; then
			break
		fi
		block="${block}"$'\n'"${line}"
	fi
done < "$FILE"

if [ -z "$block" ]; then
	echo "No extra.apply block found"
	exit 1
fi

# Store keys and values in parallel arrays (Bash 3.x compatible)
KEYS=()
VALS=()

while IFS= read -r line; do
	key=$(echo "$line" | sed -n 's/.*set("\([^"]*\)".*/\1/p')
	val=$(echo "$line" | sed -n 's/.*set("[^"]*",[[:space:]]*"\(.*\)").*/\1/p')
	if [ -n "$key" ] && [ -n "$val" ]; then
		KEYS+=("$key")
		VALS+=("$val")
	fi
done <<< "$block"

# Lookup function
get_raw_value() {
	local key="$1"
	local i
	for (( i=0; i<${#KEYS[@]}; i++ )); do
		if [ "${KEYS[$i]}" = "$key" ]; then
			echo "${VALS[$i]}"
			return
		fi
	done
}

# Recursive resolution of ${get("...")}
resolve_value() {
	local val
	val="$(get_raw_value "$1")"
	local iterations=0
	while echo "$val" | grep -q '\${get("'; do
		inner_key=$(echo "$val" | sed -n 's/.*\${get("\([^"]*\)")}.*/\1/p')
		inner_val=$(get_raw_value "$inner_key")
		val=$(echo "$val" | sed "s|\${get(\"$inner_key\")}|$inner_val|g")
		iterations=$((iterations + 1))
		[ "$iterations" -gt 10 ] && break
	done
	echo "$val"
}

# Final output
result=$(resolve_value "$PROPERTY_NAME")

if [ -n "$result" ]; then
	echo "$result"
else
	echo "Property '$PROPERTY_NAME' not found or empty in $FILE"
	exit 1
fi
