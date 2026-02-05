#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/..)
IOS_DIR=$ROOT_DIR/ios
ADDON_DIR=$ROOT_DIR/addon
ADDON_OUTPUT_DIR=$ADDON_DIR/build/output
GODOT_DIR=$IOS_DIR/godot
IOS_CONFIG_DIR=$IOS_DIR/config
COMMON_DIR=$ROOT_DIR/common
PODS_DIR=$IOS_DIR/Pods
BUILD_DIR=$IOS_DIR/build
DEST_DIR=$BUILD_DIR/release
FRAMEWORK_DIR=$BUILD_DIR/framework
LIB_DIR=$BUILD_DIR/lib
IOS_CONFIG_FILE=$IOS_CONFIG_DIR/config.properties
COMMON_CONFIG_FILE=$COMMON_DIR/config/config.properties

PLUGIN_NODE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginNodeName)
PLUGIN_NAME="${PLUGIN_NODE_NAME}Plugin"
PLUGIN_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginVersion)
PLUGIN_MODULE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginModuleName)
IOS_INITIALIZATION_METHOD="${PLUGIN_MODULE_NAME}_plugin_init"
IOS_DEINITIALIZATION_METHOD="${PLUGIN_MODULE_NAME}_plugin_deinit"
GODOT_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE godotVersion)
GODOT_RELEASE_TYPE=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE godotReleaseType)
BUILD_TIMEOUT=40	# increase this value using -t option if device is not able to generate all headers before godot build is killed

do_clean=false
do_remove_pod_trunk=false
do_remove_godot=false
do_download_godot=false
do_generate_headers=false
do_install_pods=false
do_build=false
do_create_zip=false


function display_help()
{
	echo
	$SCRIPT_DIR/echocolor.sh -y "The " -Y "$0 script" -y " builds the plugin, generates library archives, and"
	echo_yellow "creates a zip file containing all libraries and configuration."
	echo
	echo_yellow "If plugin version is not set with the -z option, then Godot version will be used."
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Syntax:"
	echo_yellow "	$0 [-a|A|c|g|G|h|H|p|P|t <timeout>|z]"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	echo_yellow "	a	generate godot headers and build plugin"
	echo_yellow "	A	download configured godot version, generate godot headers, and"
	echo_yellow "	 	build plugin"
	echo_yellow "	b	build plugin"
	echo_yellow "	c	remove any existing plugin build"
	echo_yellow "	g	remove godot directory"
	echo_yellow "	G	download the configured godot version into godot directory"
	echo_yellow "	h	display usage information"
	echo_yellow "	H	generate godot headers"
	echo_yellow "	p	remove pods and pod repo trunk"
	echo_yellow "	P	install pods"
	echo_yellow "	t	change timeout value for godot build"
	echo_yellow "	z	create zip archive, include configured version in the file name"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Examples:"
	echo_yellow "	* clean existing build, remove godot, and rebuild all"
	echo_yellow "		$> $0 -cgA"
	echo_yellow "		$> $0 -cgpGHPbz"
	echo
	echo_yellow "	* clean existing build, remove pods and pod repo trunk, and rebuild plugin"
	echo_yellow "		$> $0 -cpPb"
	echo
	echo_yellow "	* clean existing build and rebuild plugin"
	echo_yellow "		$> $0 -ca"
	echo
	echo_yellow "	* clean existing build and rebuild plugin with custom plugin version"
	echo_yellow "		$> $0 -cHbz"
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


function remove_pods()
{
	display_status "Removing Pods..."

	if [[ -d $PODS_DIR ]]
	then
		display_progress "Removing '$PODS_DIR' directory..."
		rm -rf $PODS_DIR
	else
		display_warning "'$PODS_DIR' directory does not exist"
	fi

	if [[ -f $IOS_DIR/Podfile.lock ]]
	then
		display_progress "Removing '$IOS_DIR/Podfile.lock' file..."
		rm -f $IOS_DIR/Podfile.lock
	else
		display_warning "'$IOS_DIR/Podfile.lock' file does not exist"
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

	display_status "Validating Godot version..."
	echo_blue "Expected version (from config): $expected_version"
	echo_blue "Downloaded version (from GODOT_VERSION file): $downloaded_version"

	if [[ "$downloaded_version" != "$expected_version" ]]; then
		display_error "Godot version mismatch!"
		$SCRIPT_DIR/echocolor.sh -r "  Expected: $expected_version"
		$SCRIPT_DIR/echocolor.sh -r "  Found:    $downloaded_version"
		echo
		$SCRIPT_DIR/echocolor.sh -r "The Godot version in $GODOT_DIR/GODOT_VERSION does not match"
		$SCRIPT_DIR/echocolor.sh -r "the godotVersion property in $COMMON_CONFIG_FILE"
		echo
		exit 1
	fi

	display_progress "Godot version validation passed: $expected_version"
}


function install_pods()
{
	display_status "Installing pods..."
	pod install --repo-update --project-directory=$IOS_DIR/ || true
}


function build_plugin()
{
	if [[ ! -d "$PODS_DIR" ]]; then
		display_error "Pods directory does not exist. Run 'pod install' first."
		exit 1
	fi

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

	SCHEME=${1:-${PLUGIN_MODULE_NAME}_plugin}
	PROJECT=${2:-${PLUGIN_MODULE_NAME}_plugin.xcodeproj}
	WORKSPACE="${PROJECT}/project.xcworkspace"
	OUT=${PLUGIN_NAME}
	CLASS=${PLUGIN_NAME}

	mkdir -p $FRAMEWORK_DIR
	mkdir -p $LIB_DIR

	display_status "Building iOS release"
	xcodebuild archive \
		-workspace "$IOS_DIR/$WORKSPACE" \
		-scheme $SCHEME \
		-archivePath "$LIB_DIR/ios_release.xcarchive" \
		-derivedDataPath "$BUILD_DIR/DerivedData" \
		-sdk iphoneos \
		SKIP_INSTALL=NO \
		GCC_GENERATE_DEPENDENCIES=NO

	display_status "Building iOS simulator release"
	xcodebuild archive \
		-workspace "$IOS_DIR/$WORKSPACE" \
		-scheme $SCHEME \
		-archivePath "$LIB_DIR/sim_release.xcarchive" \
		-derivedDataPath "$BUILD_DIR/DerivedData" \
		-sdk iphonesimulator \
		SKIP_INSTALL=NO \
		GCC_GENERATE_DEPENDENCIES=NO

	display_status "Building iOS debug"
	xcodebuild archive \
		-workspace "$IOS_DIR/$WORKSPACE" \
		-scheme $SCHEME \
		-archivePath "$LIB_DIR/ios_debug.xcarchive" \
		-derivedDataPath "$BUILD_DIR/DerivedData" \
		-sdk iphoneos \
		SKIP_INSTALL=NO \
		GCC_PREPROCESSOR_DEFINITIONS="DEBUG_ENABLED=1" \
		GCC_GENERATE_DEPENDENCIES=NO

	display_status "Building iOS simulator debug"
	xcodebuild archive \
		-workspace "$IOS_DIR/$WORKSPACE" \
		-scheme $SCHEME \
		-archivePath "$LIB_DIR/sim_debug.xcarchive" \
		-derivedDataPath "$BUILD_DIR/DerivedData" \
		-sdk iphonesimulator \
		SKIP_INSTALL=NO \
		GCC_PREPROCESSOR_DEFINITIONS="DEBUG_ENABLED=1" \
		GCC_GENERATE_DEPENDENCIES=NO

	mv $LIB_DIR/ios_release.xcarchive/Products/usr/local/lib/lib${SCHEME}.a $LIB_DIR/ios_release.xcarchive/Products/usr/local/lib/${OUT}.a
	mv $LIB_DIR/sim_release.xcarchive/Products/usr/local/lib/lib${SCHEME}.a $LIB_DIR/sim_release.xcarchive/Products/usr/local/lib/${OUT}.a
	mv $LIB_DIR/ios_debug.xcarchive/Products/usr/local/lib/lib${SCHEME}.a $LIB_DIR/ios_debug.xcarchive/Products/usr/local/lib/${OUT}.a
	mv $LIB_DIR/sim_debug.xcarchive/Products/usr/local/lib/lib${SCHEME}.a $LIB_DIR/sim_debug.xcarchive/Products/usr/local/lib/${OUT}.a

	if [[ -d "$FRAMEWORK_DIR/${OUT}.release.xcframework" ]]
	then
		rm -rf $FRAMEWORK_DIR/${OUT}.release.xcframework
	fi

	if [[ -d "$FRAMEWORK_DIR/${OUT}.debug.xcframework" ]]
	then
		rm -rf $FRAMEWORK_DIR/${OUT}.debug.xcframework
	fi

	display_status "Creating release framework"
	xcodebuild -create-xcframework \
		-library "$LIB_DIR/ios_release.xcarchive/Products/usr/local/lib/${OUT}.a" \
		-library "$LIB_DIR/sim_release.xcarchive/Products/usr/local/lib/${OUT}.a" \
		-output "$FRAMEWORK_DIR/${OUT}.release.xcframework"

	display_status "Creating debug framework"
	xcodebuild -create-xcframework \
		-library "$LIB_DIR/ios_debug.xcarchive/Products/usr/local/lib/${OUT}.a" \
		-library "$LIB_DIR/sim_debug.xcarchive/Products/usr/local/lib/${OUT}.a" \
		-output "$FRAMEWORK_DIR/${OUT}.debug.xcframework"
}


function create_zip_archive()
{
	local zip_file_name="$PLUGIN_NAME-iOS-v$PLUGIN_VERSION.zip"

	if [[ -e "$DEST_DIR/$zip_file_name" ]]
	then
		display_warning "deleting existing $zip_file_name file..."
		rm $DEST_DIR/$zip_file_name
	fi

	local tmp_directory=$(mktemp -d)

	$SCRIPT_DIR/run_gradle_task.sh "generateGDScript"

	display_status "Preparing staging directory $tmp_directory"

	if [[ -d "$ADDON_OUTPUT_DIR" ]]
	then
		cp -r $ADDON_OUTPUT_DIR/* $tmp_directory

		mkdir -p $tmp_directory/ios/plugins
		cp $IOS_CONFIG_DIR/*.gdip $tmp_directory/ios/plugins

		# Detect OS
		if [[ "$OSTYPE" == "darwin"* ]]; then
			# macOS: use -i ''
			SED_INPLACE=(-i '')
		else
			# Linux: use -i with no backup suffix
			SED_INPLACE=(-i)
		fi

		find "$tmp_directory" -type f \( -name '*.gdip' \) | while IFS= read -r file; do
			display_progress "Editing: $file"

			# Escape variables to handle special characters
			ESCAPED_PLUGIN_NAME=$(printf '%s' "$PLUGIN_NAME" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_INITIALIZATION_METHOD=$(printf '%s' "$IOS_INITIALIZATION_METHOD" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_DEINITIALIZATION_METHOD=$(printf '%s' "$IOS_DEINITIALIZATION_METHOD" | sed 's/[\/&]/\\&/g')

			sed "${SED_INPLACE[@]}" -e "
				s|@pluginName@|$ESCAPED_PLUGIN_NAME|g;
				s|@iosInitializationMethod@|$ESCAPED_IOS_INITIALIZATION_METHOD|g;
				s|@iosDeinitializationMethod@|$ESCAPED_IOS_DEINITIALIZATION_METHOD|g
			" "$file"
		done
	else
		display_error "'$ADDON_OUTPUT_DIR' not found."
		exit 1
	fi

	# Stream -print0 output directly into the loop
	found_any=false

	while IFS= read -r -d '' item; do
		if [ "$found_any" = false ]; then
			display_progress "Frameworks found in $PODS_DIR. Creating destination directory..."
			mkdir -p "$tmp_directory/ios/framework"
			found_any=true
		fi

		display_progress "Copying framework: $item"
		cp -r "$item" "$tmp_directory/ios/framework"

	done < <(find "$PODS_DIR" -iname '*.xcframework' -type d -print0)

	# If none found
	if [ "$found_any" = false ]; then
		display_warning "No .xcframework items found in $PODS_DIR. Skipping directory creation and copy operation."
	fi

	cp -r $FRAMEWORK_DIR/$PLUGIN_NAME.{release,debug}.xcframework $tmp_directory/ios/plugins

	mkdir -p $DEST_DIR

	display_status "Creating $zip_file_name file..."
	cd $tmp_directory; zip -yr $DEST_DIR/$zip_file_name ./*; cd -

	rm -rf $tmp_directory
}


while getopts "aAbcgGhHpPt:z" option; do
	case $option in
		h)
			display_help
			exit;;
		a)
			do_generate_headers=true
			do_install_pods=true
			do_build=true
			;;
		A)
			do_download_godot=true
			do_generate_headers=true
			do_install_pods=true
			do_build=true
			;;
		b)
			do_build=true
			;;
		c)
			do_clean=true
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
			do_remove_pod_trunk=true
			;;
		P)
			do_install_pods=true
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
		z)
			do_create_zip=true
			;;
		\?)
			display_error "invalid option"
			echo
			display_help
			exit;;
	esac
done

if [[ "$do_clean" == true ]]
then
	clean_plugin_build
fi

if [[ "$do_remove_pod_trunk" == true ]]
then
	remove_pods
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

if [[ "$do_install_pods" == true ]]
then
	install_pods
fi

if [[ "$do_build" == true ]]
then
	build_plugin
fi

if [[ "$do_create_zip" == true ]]
then
	create_zip_archive
fi
