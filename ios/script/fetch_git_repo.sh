#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

# Function to show usage
usage() {
	echo "Usage: $0 [-t <tag>] <repo_url> <target_directory>"
	exit 1
}

# Parse options
TAG=""
while getopts ":t:" opt; do
	case $opt in
	t)
		TAG="$OPTARG"
		;;
	\?)
		echo "Invalid option: -$OPTARG" >&2
		usage
		;;
	:)
		echo "Option -$OPTARG requires an argument." >&2
		usage
		;;
	esac
done

shift $((OPTIND -1))

# Validate positional arguments
if [ $# -ne 2 ]; then
	usage
fi

REPO_URL="$1"
TARGET_DIR="$2"

# Function to check if a remote tag exists
tag_exists() {
	git ls-remote --tags "$1" | grep -q "refs/tags/$2$"
}

# Determine cloning strategy
if [ -n "$TAG" ]; then
	echo "Checking if tag '$TAG' exists in the repository..."

	if tag_exists "$REPO_URL" "$TAG"; then
		echo "Tag '$TAG' found. Cloning..."
		git clone --branch "$TAG" --depth 1 "$REPO_URL" "$TARGET_DIR"
	else
		echo "Warning: Tag '$TAG' not found. Falling back to latest commit on 'master' branch..."
		git clone --branch master --depth 1 "$REPO_URL" "$TARGET_DIR"
	fi
else
	echo "No tag specified. Cloning latest commit from 'master'..."
	git clone --branch master --depth 1 "$REPO_URL" "$TARGET_DIR"
fi

# Check for success
if [ $? -ne 0 ]; then
	echo "Failed to clone repository."
	exit 1
fi

echo "Repository successfully cloned into '$TARGET_DIR'."
