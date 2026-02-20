#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/..)
IOS_DIR=$ROOT_DIR/ios
IOS_CONFIG_DIR=$IOS_DIR/config
COMMON_DIR=$ROOT_DIR/common
BUILD_DIR=$IOS_DIR/build
DERIVED_DATA_DIR=$BUILD_DIR/DerivedData
SOURCE_PACKAGES_DIR=$DERIVED_DATA_DIR/SourcePackages
FRAMEWORK_DIR=$BUILD_DIR/framework
LIB_DIR=$BUILD_DIR/lib

IOS_CONFIG_FILE=$IOS_CONFIG_DIR/config.properties
COMMON_CONFIG_FILE=$COMMON_DIR/config/config.properties
LOCAL_PROPERTIES_FILE=$COMMON_DIR/local.properties

# Resolve GODOT_DIR: use godot.dir from local.properties if set, otherwise default to $IOS_DIR/godot
GODOT_DIR=$IOS_DIR/godot
if [[ -f "$LOCAL_PROPERTIES_FILE" ]]; then
	_godot_dir_prop=$($SCRIPT_DIR/get_config_property.sh -f "$LOCAL_PROPERTIES_FILE" godot.dir)
	if [[ -n "$_godot_dir_prop" ]]; then
		GODOT_DIR=$(eval echo "$_godot_dir_prop")
	fi
	unset _godot_dir_prop
fi

PLUGIN_NODE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginNodeName)
PLUGIN_NAME="${PLUGIN_NODE_NAME}Plugin"
PLUGIN_MODULE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginModuleName)
GODOT_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE godotVersion)
GODOT_RELEASE_TYPE=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE godotReleaseType)

IOS_DEPENDENCIES=()
while IFS= read -r line; do
	IOS_DEPENDENCIES+=("$line")
done < <($SCRIPT_DIR/get_config_property.sh -a -f $IOS_CONFIG_FILE dependencies)

SCHEME="${PLUGIN_MODULE_NAME}_plugin"
PROJECT="${SCHEME}.xcodeproj"
WORKSPACE="${PROJECT}/project.xcworkspace"
SPM_DIR=$IOS_DIR/$WORKSPACE/xcshareddata/swiftpm

BUILD_TIMEOUT=40	# increase this value using -t option if device is not able to generate all headers before godot build is killed

do_clean=false
do_remove_spm_cache=false
do_remove_godot=false
do_download_godot=false
do_generate_headers=false
do_update_spm=false
do_build=false
do_create_archive=false
do_uninstall=false
do_install=false


function display_help()
{
	echo
	$SCRIPT_DIR/echocolor.sh -y "The " -Y "$0 script" -y " builds the plugin, generates library archives, and"
	echo_yellow "creates a zip file containing all libraries and configuration."
	echo
	echo_yellow "If plugin version is not set with the -z option, then Godot version will be used."
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Syntax:"
	echo_yellow "	$0 [-a|A|b|c|d|D|g|G|h|H|p|P|R|t <timeout>]"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	echo_yellow "	a	generate godot headers and build plugin"
	echo_yellow "	A	download configured godot version, generate godot headers, and"
	echo_yellow "	 	build plugin"
	echo_yellow "	b	build plugin"
	echo_yellow "	c	remove any existing plugin build"
	echo_yellow "	d	uninstall iOS plugin from demo app"
	echo_yellow "	D	install iOS plugin to demo app"
	echo_yellow "	g	remove godot directory"
	echo_yellow "	G	download the configured godot version into godot directory"
	echo_yellow "	h	display usage information"
	echo_yellow "	H	generate godot headers"
	echo_yellow "	p	remove SPM packages and build artifacts"
	echo_yellow "	P	add SPM packages from configuration"
	echo_yellow "	R	create iOS release archive"
	echo_yellow "	t	change timeout value for godot build"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Examples:"
	echo_yellow "	* clean existing build, remove godot, and rebuild all"
	echo_yellow "		$> $0 -cgA"
	echo_yellow "		$> $0 -cgpGHPb"
	echo
	echo_yellow "	* clean existing build, remove SPM packages, and rebuild plugin"
	echo_yellow "		$> $0 -cpPb"
	echo
	echo_yellow "	* clean existing build and rebuild plugin"
	echo_yellow "		$> $0 -ca"
	echo
	echo_yellow "	* clean existing build and rebuild plugin and create release archive"
	echo_yellow "		$> $0 -R"
	echo
	echo_yellow "	* clean existing build and rebuild plugin with custom build-header timeout"
	echo_yellow "		$> $0 -cHbt 15"
	echo
}


function echo_yellow()
{
	$SCRIPT_DIR/echocolor.sh -y "$1"
}


function echo_blue()
{
	$SCRIPT_DIR/echocolor.sh -B "$1"
}


function echo_green()
{
	$SCRIPT_DIR/echocolor.sh -g "$1"
}


function display_status()
{
	echo
	$SCRIPT_DIR/echocolor.sh -c "********************************************************************************"
	$SCRIPT_DIR/echocolor.sh -c "* $1"
	$SCRIPT_DIR/echocolor.sh -c "********************************************************************************"
	echo
}


function display_progress()
{
	echo_green "$1"
	echo
}


function display_warning()
{
	echo_yellow "Warning: $1"
	echo
}


function display_error()
{
	$SCRIPT_DIR/echocolor.sh -r "Error: $1"
}


function remove_godot_directory()
{
	if [[ -d "$GODOT_DIR" ]]
	then
		display_status "Removing '$GODOT_DIR' directory..."
		rm -rf $GODOT_DIR
	else
		display_warning "'$GODOT_DIR' directory not found!"
	fi
}


function clean_plugin_build()
{
	display_status "Cleaning plugin build..."

	if [[ -d "$BUILD_DIR" ]]
	then
		display_progress "Removing '$BUILD_DIR' directory..."
		rm -rf $BUILD_DIR
	else
		display_warning "'$BUILD_DIR' directory not found!"
	fi

	display_progress "Cleaning generated files..."
	find . -name "*.d" -type f -delete
	find . -name "*.o" -type f -delete
}


function remove_spm_cache()
{
	display_status "Removing SPM Cache..."
	if [[ -d $SOURCE_PACKAGES_DIR ]]; then
		display_progress "Removing $SOURCE_PACKAGES_DIR ..."
		rm -rf $SOURCE_PACKAGES_DIR
	fi
}


function download_godot()
{
	if [[ -d "$GODOT_DIR" ]]; then
		display_error "$GODOT_DIR directory already exists. Remove it first or use a different directory."
		exit 1
	fi

	local filename="godot-${GODOT_VERSION}-${GODOT_RELEASE_TYPE}.tar.xz"
	local release_url="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-${GODOT_RELEASE_TYPE}/${filename}"
	local archive_path="${GODOT_DIR}.tar.xz"
	local temp_extract_dir=$(mktemp -d)

	display_status "Downloading Godot ${GODOT_VERSION}-${GODOT_RELEASE_TYPE} (official pre-built binary)..."
	echo_blue "URL: $release_url"

	# Check required tools
	if ! command -v curl >/dev/null 2>&1; then
		display_error "curl is required to download the archive."
		exit 1
	fi
	if ! command -v tar >/dev/null 2>&1; then
		display_error "tar is required to extract the archive."
		exit 1
	fi

	# Download the .tar.xz archive
	if ! curl -L --fail --progress-bar -o "$archive_path" "$release_url"; then
		rm -f "$archive_path"
		display_error "Failed to download Godot binary from:\n$release_url\nPlease verify that GODOT_VERSION (${GODOT_VERSION}) and GODOT_RELEASE_TYPE (${GODOT_RELEASE_TYPE}) are correct."
		exit 1
	fi

	display_status "Extracting $filename ..."
	if ! tar -xaf "$archive_path" -C "$temp_extract_dir" --strip-components=1; then
		rm -f "$archive_path"
		rm -rf "$temp_extract_dir"
		display_error "Failed to extract the .tar.xz archive."
		exit 1
	fi

	# Move extracted contents to final destination
	mkdir -p "$GODOT_DIR"
	mv "$temp_extract_dir"/* "$GODOT_DIR"/

	# Cleanup
	rm -f "$archive_path"
	rm -rf "$temp_extract_dir"

	# Write version marker for the rest of the build system
	echo "$GODOT_VERSION" > "$GODOT_DIR/GODOT_VERSION"

	display_progress "Godot ${GODOT_VERSION}-${GODOT_RELEASE_TYPE} successfully downloaded and extracted to $GODOT_DIR"
}


function generate_godot_headers()
{
	if [[ ! -d "$GODOT_DIR" ]]
	then
		display_error "$GODOT_DIR directory does not exist. Can't generate headers."
		exit 1
	fi

	display_status "Starting Godot build to generate Godot headers..."

	$SCRIPT_DIR/run_with_timeout.sh -t $BUILD_TIMEOUT -c "scons platform=ios target=template_release" -d $GODOT_DIR || true

	display_status "Terminated Godot build after $BUILD_TIMEOUT seconds..."
}


function validate_godot_version()
{
	if [[ ! -f "$GODOT_DIR/GODOT_VERSION" ]]; then
		display_error "GODOT_VERSION file not found in $GODOT_DIR"
		exit 1
	fi

	local downloaded_version=$(cat "$GODOT_DIR/GODOT_VERSION" | tr -d '[:space:]')
	local expected_version="$GODOT_VERSION"

	display_status "Validating Godot version in $GODOT_DIR..."
	echo_blue "Expected version (from config): $expected_version"
	echo_blue "Downloaded version (from GODOT_VERSION file): $downloaded_version"

	if [[ "$downloaded_version" != "$expected_version" ]]; then
		display_error "Godot version mismatch!"
		$SCRIPT_DIR/echocolor.sh -r "	Expected:	$expected_version"
		$SCRIPT_DIR/echocolor.sh -r "	Found:		$downloaded_version"
		echo
		$SCRIPT_DIR/echocolor.sh -r "The Godot version in $GODOT_DIR/GODOT_VERSION does not match"
		$SCRIPT_DIR/echocolor.sh -r "the godotVersion property in $COMMON_CONFIG_FILE"
		echo
		exit 1
	fi

	display_progress "Godot version validation passed: $expected_version"
}


function update_spm()
{
	display_status "Updating SPM dependencies..."

	if ! command -v ruby >/dev/null 2>&1; then
		display_error "Ruby is required to inject SPM dependencies."
		exit 1
	fi

	if ! gem list -i "^xcodeproj$" >/dev/null 2>&1; then
		display_progress "Installing 'xcodeproj' Ruby gem..."
		gem install xcodeproj --user-install
	fi

	local count=0
	for i in "${IOS_DEPENDENCIES[@]}"; do
		[[ -n "$i" ]] && ((count++))
	done

	if [ "$count" -eq 0 ]; then
		display_warning "No dependencies found for plugin. Skipping SPM update."
	else
		local noun="dependencies"
		if [ "$count" -eq 1 ]; then
			noun="dependency"
		fi

		display_progress "Found $count SPM $noun:"

		local dep
		for dep in "${IOS_DEPENDENCIES[@]}"; do
			if [[ -n "$dep" ]]; then
				echo "	• $dep"
			fi
		done

		echo ""

		display_progress "Updating Package.swift with dependencies..."
		ruby "$SCRIPT_DIR/spm_manager.rb" "$IOS_DIR/$PROJECT" "${IOS_DEPENDENCIES[@]}"

		display_progress "Resolving SPM packages..."
		xcodebuild -resolvePackageDependencies \
			-project "$IOS_DIR/$PROJECT" \
			-scheme "$SCHEME" \
			-derivedDataPath "$DERIVED_DATA_DIR" \
			GODOT_DIR="$GODOT_DIR" || true

		display_status "SPM update completed."
	fi
}


function build_plugin()
{
	if [[ ! -d "$GODOT_DIR" ]]; then
		display_error "$GODOT_DIR directory does not exist. Can't build plugin."
		exit 1
	fi

	if [[ ! -f "$GODOT_DIR/GODOT_VERSION" ]]
	then
		display_error "godot wasn't downloaded properly. Can't build plugin."
		exit 1
	fi

	# Validate that the Godot version matches the configured version
	validate_godot_version

	if [[ ! -d "$SPM_DIR" ]]; then
		display_warning "Swift Package Manager directory does not exist. Run with '-P' option if project has dependencies."
	fi

	mkdir -p $FRAMEWORK_DIR
	mkdir -p $LIB_DIR

	display_status "Building iOS release"
	xcodebuild archive \
		-workspace "$IOS_DIR/$WORKSPACE" \
		-scheme $SCHEME \
		-archivePath "$LIB_DIR/ios_release.xcarchive" \
		-derivedDataPath "$DERIVED_DATA_DIR/ios_release" \
		-sdk iphoneos \
		SKIP_INSTALL=NO \
		GODOT_DIR="$GODOT_DIR"

	display_status "Building iOS simulator release"
	xcodebuild archive \
		-workspace "$IOS_DIR/$WORKSPACE" \
		-scheme $SCHEME \
		-archivePath "$LIB_DIR/sim_release.xcarchive" \
		-derivedDataPath "$DERIVED_DATA_DIR/ios_simulator_release" \
		-sdk iphonesimulator \
		SKIP_INSTALL=NO \
		GODOT_DIR="$GODOT_DIR"

	display_status "Building iOS debug"
	xcodebuild archive \
		-workspace "$IOS_DIR/$WORKSPACE" \
		-scheme $SCHEME \
		-archivePath "$LIB_DIR/ios_debug.xcarchive" \
		-derivedDataPath "$DERIVED_DATA_DIR/ios_debug" \
		-sdk iphoneos \
		SKIP_INSTALL=NO \
		GCC_PREPROCESSOR_DEFINITIONS="\$(inherited) DEBUG_ENABLED=1" \
		GODOT_DIR="$GODOT_DIR"

	display_status "Building iOS simulator debug"
	xcodebuild archive \
		-workspace "$IOS_DIR/$WORKSPACE" \
		-scheme $SCHEME \
		-archivePath "$LIB_DIR/sim_debug.xcarchive" \
		-derivedDataPath "$DERIVED_DATA_DIR/ios_simulator_debug" \
		-sdk iphonesimulator \
		SKIP_INSTALL=NO \
		GCC_PREPROCESSOR_DEFINITIONS="\$(inherited) DEBUG_ENABLED=1" \
		GODOT_DIR="$GODOT_DIR"

	mv $LIB_DIR/ios_release.xcarchive/Products/usr/local/lib/lib${SCHEME}.a $LIB_DIR/ios_release.xcarchive/Products/usr/local/lib/${PLUGIN_NAME}.a
	mv $LIB_DIR/sim_release.xcarchive/Products/usr/local/lib/lib${SCHEME}.a $LIB_DIR/sim_release.xcarchive/Products/usr/local/lib/${PLUGIN_NAME}.a
	mv $LIB_DIR/ios_debug.xcarchive/Products/usr/local/lib/lib${SCHEME}.a $LIB_DIR/ios_debug.xcarchive/Products/usr/local/lib/${PLUGIN_NAME}.a
	mv $LIB_DIR/sim_debug.xcarchive/Products/usr/local/lib/lib${SCHEME}.a $LIB_DIR/sim_debug.xcarchive/Products/usr/local/lib/${PLUGIN_NAME}.a

	if [[ -d "$FRAMEWORK_DIR/${PLUGIN_NAME}.release.xcframework" ]]
	then
		rm -rf $FRAMEWORK_DIR/${PLUGIN_NAME}.release.xcframework
	fi

	if [[ -d "$FRAMEWORK_DIR/${PLUGIN_NAME}.debug.xcframework" ]]
	then
		rm -rf $FRAMEWORK_DIR/${PLUGIN_NAME}.debug.xcframework
	fi

	display_status "Creating release framework"
	xcodebuild -create-xcframework \
		-library "$LIB_DIR/ios_release.xcarchive/Products/usr/local/lib/${PLUGIN_NAME}.a" \
		-library "$LIB_DIR/sim_release.xcarchive/Products/usr/local/lib/${PLUGIN_NAME}.a" \
		-output "$FRAMEWORK_DIR/${PLUGIN_NAME}.release.xcframework"

	display_status "Creating debug framework"
	xcodebuild -create-xcframework \
		-library "$LIB_DIR/ios_debug.xcarchive/Products/usr/local/lib/${PLUGIN_NAME}.a" \
		-library "$LIB_DIR/sim_debug.xcarchive/Products/usr/local/lib/${PLUGIN_NAME}.a" \
		-output "$FRAMEWORK_DIR/${PLUGIN_NAME}.debug.xcframework"
}


while getopts "aAbcdDgGhHpPRt:" option; do
	case $option in
		h)
			display_help
			exit;;
		a)
			do_generate_headers=true
			do_update_spm=true
			do_build=true
			;;
		A)
			do_download_godot=true
			do_generate_headers=true
			do_update_spm=true
			do_build=true
			;;
		b)
			do_build=true
			;;
		c)
			do_clean=true
			;;
		d)
			do_uninstall=true
			;;
		D)
			do_install=true
			;;
		g)
			do_remove_godot=true
			;;
		G)
			do_download_godot=true
			;;
		H)
			do_generate_headers=true
			;;
		p)
			do_remove_spm_cache=true
			;;
		P)
			do_update_spm=true
			;;
		R)
			do_create_archive=true
			;;
		t)
			regex='^[0-9]+$'
			if ! [[ $OPTARG =~ $regex ]]
			then
				display_error "The argument for the -t option should be an integer. Found $OPTARG."
				echo
				display_help
				exit 1
			else
				BUILD_TIMEOUT=$OPTARG
			fi
			;;
		\?)
			display_error "invalid option"
			echo
			display_help
			exit;;
	esac
done


if [[ "$do_uninstall" == true ]]
then
	display_status "Uninstalling iOS plugin from demo app"
	$SCRIPT_DIR/run_gradle_task.sh "uninstalliOS"
fi

if [[ "$do_clean" == true ]]
then
	clean_plugin_build
fi

if [[ "$do_remove_spm_cache" == true ]]
then
	remove_spm_cache
fi

if [[ "$do_remove_godot" == true ]]
then
	remove_godot_directory
fi

if [[ "$do_download_godot" == true ]]
then
	download_godot
fi

if [[ "$do_generate_headers" == true ]]
then
	generate_godot_headers
fi

if [[ "$do_update_spm" == true ]]
then
	if [[ "${INVOKED_BY_GRADLE:-}" == "true" ]]; then
		update_spm
	else
		$SCRIPT_DIR/run_gradle_task.sh "resolveSPMPackages"
	fi
fi

if [[ "$do_build" == true ]]
then
	if [[ "${INVOKED_BY_GRADLE:-}" == "true" ]]; then
		build_plugin
	else
		$SCRIPT_DIR/run_gradle_task.sh "buildiOS"
	fi
fi

if [[ "$do_create_archive" == true ]]
then
	display_status "Creating iOS archive"
	$SCRIPT_DIR/run_gradle_task.sh "createiOSArchive"
fi

if [[ "$do_install" == true ]]
then
	display_status "Installing iOS plugin to demo app"
	$SCRIPT_DIR/run_gradle_task.sh "installToDemoiOS"
fi
