#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -e
trap "sleep 1; echo" EXIT

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
IOS_DIR=$(realpath $SCRIPT_DIR/..)
ROOT_DIR=$(realpath $IOS_DIR/..)
ANDROID_DIR=$ROOT_DIR/android
ADDON_DIR=$ROOT_DIR/addon
GODOT_DIR=$IOS_DIR/godot
IOS_CONFIG_DIR=$IOS_DIR/config
PODS_DIR=$IOS_DIR/Pods
BUILD_DIR=$IOS_DIR/build
DEST_DIR=$BUILD_DIR/release
FRAMEWORK_DIR=$BUILD_DIR/framework
LIB_DIR=$BUILD_DIR/lib
IOS_CONFIG_FILE=$IOS_CONFIG_DIR/config.properties
COMMON_CONFIG_FILE=$ROOT_DIR/common/config.properties

PLUGIN_NODE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginNodeName)
PLUGIN_NAME="${PLUGIN_NODE_NAME}Plugin"
PLUGIN_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginVersion)
IOS_INITIALIZATION_METHOD=$($SCRIPT_DIR/get_config_property.sh -f $IOS_CONFIG_FILE initialization_method)
IOS_DEINITIALIZATION_METHOD=$($SCRIPT_DIR/get_config_property.sh -f $IOS_CONFIG_FILE deinitialization_method)
PLUGIN_PACKAGE_NAME=$($SCRIPT_DIR/get_gradle_property.sh pluginPackageName $ANDROID_DIR/config.gradle.kts)
ANDROID_DEPENDENCIES=$($SCRIPT_DIR/get_android_dependencies.sh)
GODOT_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE godotVersion)
IOS_FRAMEWORKS=()
while IFS= read -r line; do
	IOS_FRAMEWORKS+=("$line")
done < <($SCRIPT_DIR/get_config_property.sh -qa -f $IOS_CONFIG_FILE frameworks)
IOS_EMBEDDED_FRAMEWORKS=()
while IFS= read -r line; do
	IOS_EMBEDDED_FRAMEWORKS+=("$line")
done < <($SCRIPT_DIR/get_config_property.sh -qa -f $IOS_CONFIG_FILE embedded_frameworks)
IOS_LINKER_FLAGS=()
while IFS= read -r line; do
	IOS_LINKER_FLAGS+=("$line")
done < <($SCRIPT_DIR/get_config_property.sh -qa -f $IOS_CONFIG_FILE flags)
SUPPORTED_GODOT_VERSIONS=()
while IFS= read -r line; do
	SUPPORTED_GODOT_VERSIONS+=($line)
done < <($SCRIPT_DIR/get_config_property.sh -a -f $IOS_CONFIG_FILE valid_godot_versions)
EXTRA_PROPERTIES=()
while IFS= read -r line; do
	EXTRA_PROPERTIES+=($line)
done < <($SCRIPT_DIR/get_config_property.sh -a -f $IOS_CONFIG_FILE extra_properties)
BUILD_TIMEOUT=40	# increase this value using -t option if device is not able to generate all headers before godot build is killed

do_clean=false
do_remove_pod_trunk=false
do_remove_godot=false
do_download_godot=false
do_generate_headers=false
do_install_pods=false
do_build=false
do_create_zip=false
ignore_unsupported_godot_version=false


function display_help()
{
	echo
	$ROOT_DIR/script/echocolor.sh -y "The " -Y "$0 script" -y " builds the plugin, generates library archives, and"
	echo_yellow "creates a zip file containing all libraries and configuration."
	echo
	echo_yellow "If plugin version is not set with the -z option, then Godot version will be used."
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Syntax:"
	echo_yellow "	$0 [-a|A|c|g|G|h|H|i|p|P|t <timeout>|z]"
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Options:"
	echo_yellow "	a	generate godot headers and build plugin"
	echo_yellow "	A	download configured godot version, generate godot headers, and"
	echo_yellow "	 	build plugin"
	echo_yellow "	b	build plugin"
	echo_yellow "	c	remove any existing plugin build"
	echo_yellow "	g	remove godot directory"
	echo_yellow "	G	download the configured godot version into godot directory"
	echo_yellow "	h	display usage information"
	echo_yellow "	H	generate godot headers"
	echo_yellow "	i	ignore if an unsupported godot version selected and continue"
	echo_yellow "	p	remove pods and pod repo trunk"
	echo_yellow "	P	install pods"
	echo_yellow "	t	change timeout value for godot build"
	echo_yellow "	z	create zip archive, include configured version in the file name"
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Examples:"
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
	$ROOT_DIR/script/echocolor.sh -y "$1"
}


function echo_blue()
{
	$ROOT_DIR/script/echocolor.sh -b "$1"
}


function echo_green()
{
	$ROOT_DIR/script/echocolor.sh -g "$1"
}


function display_status()
{
	echo
	$ROOT_DIR/script/echocolor.sh -c "********************************************************************************"
	$ROOT_DIR/script/echocolor.sh -c "* $1"
	$ROOT_DIR/script/echocolor.sh -c "********************************************************************************"
	echo
}


function display_warning()
{
	echo_yellow "$1"
}


function display_error()
{
	$ROOT_DIR/script/echocolor.sh -r "$1"
}


function remove_godot_directory()
{
	if [[ -d "$GODOT_DIR" ]]
	then
		display_status "removing '$GODOT_DIR' directory..."
		rm -rf $GODOT_DIR
	else
		display_warning "'$GODOT_DIR' directory not found!"
	fi
}


function clean_plugin_build()
{
	if [[ -d "$BUILD_DIR" ]]
	then
		display_status "removing '$BUILD_DIR' directory..."
		rm -rf $BUILD_DIR
	else
		display_warning "'$BUILD_DIR' directory not found!"
	fi
	display_status "cleaning generated files..."
	find . -name "*.d" -type f -delete
	find . -name "*.o" -type f -delete
}


function remove_pods()
{
	if [[ -d $PODS_DIR ]]
	then
		display_status "removing '$PODS_DIR' directory..."
		rm -rf $PODS_DIR
	else
		display_warning "Warning: '$PODS_DIR' directory does not exist"
	fi
}


function download_godot()
{
	if [[ -d "$GODOT_DIR" ]]
	then
		display_error "Error: $GODOT_DIR directory already exists. Won't download."
		exit 1
	fi

	display_status "downloading godot version $GODOT_VERSION..."

	$SCRIPT_DIR/fetch_git_repo.sh -t $GODOT_VERSION-stable https://github.com/godotengine/godot.git $GODOT_DIR

	if [[ -d "$GODOT_DIR" ]]
	then
		echo "$GODOT_VERSION" > $GODOT_DIR/GODOT_VERSION
	fi
}


function generate_godot_headers()
{
	if [[ ! -d "$GODOT_DIR" ]]
	then
		display_error "Error: $GODOT_DIR directory does not exist. Can't generate headers."
		exit 1
	fi

	display_status "starting godot build to generate godot headers..."

	$SCRIPT_DIR/run_with_timeout.sh -t $BUILD_TIMEOUT -c "scons platform=ios target=template_release" -d $GODOT_DIR || true

	display_status "terminated godot build after $BUILD_TIMEOUT seconds..."
}


function generate_static_library()
{
	if [[ ! -f "$GODOT_DIR/GODOT_VERSION" ]]
	then
		display_error "Error: godot wasn't downloaded properly. Can't generate static library."
		exit 1
	fi

	TARGET_TYPE="$1"
	lib_directory="$2"

	display_status "generating static libraries for $PLUGIN_NAME with target type $TARGET_TYPE..."

	# ARM64 Device
	scons target=$TARGET_TYPE arch=arm64 target_name=$PLUGIN_NAME version=$GODOT_VERSION
	# x86_64 Simulator
	scons target=$TARGET_TYPE arch=x86_64 simulator=yes target_name=$PLUGIN_NAME version=$GODOT_VERSION

	# Creating fat library for device and simulator
	lipo -create "$lib_directory/lib$PLUGIN_NAME.x86_64-simulator.$TARGET_TYPE.a" \
		"$lib_directory/lib$PLUGIN_NAME.arm64-ios.$TARGET_TYPE.a" \
		-output "$lib_directory/$PLUGIN_NAME.$TARGET_TYPE.a"
}


function install_pods()
{
	display_status "installing pods..."
	pod install --repo-update --project-directory=$IOS_DIR/ || true
}


function build_plugin()
{
	if [[ ! -f "$GODOT_DIR/GODOT_VERSION" ]]
	then
		display_error "Error: godot wasn't downloaded properly. Can't build plugin."
		exit 1
	fi

	# Clear target directories
	rm -rf "$DEST_DIR"
	rm -rf "$LIB_DIR"

	# Create target directories
	mkdir -p "$DEST_DIR"
	mkdir -p "$LIB_DIR"

	display_status "building plugin library with godot version $GODOT_VERSION ..."

	# Compile library
	generate_static_library release $LIB_DIR
	generate_static_library release_debug $LIB_DIR
	mv $LIB_DIR/$PLUGIN_NAME.release_debug.a $LIB_DIR/$PLUGIN_NAME.debug.a

	# Move library
	cp $LIB_DIR/$PLUGIN_NAME.{release,debug}.a "$DEST_DIR"

	cp "$IOS_CONFIG_DIR"/*.gdip "$DEST_DIR"
}


function merge_string_array() {
	local arr=("$@")	# Accept array as input
	printf "%s" "${arr[0]}"
	for ((i=1; i<${#arr[@]}; i++)); do
		printf ", %s" "${arr[i]}"
	done
}


function replace_extra_properties() {
	local file_path="$1"
	local -a prop_array=("${@:2}")

	# Check if file exists and is readable
	if [[ ! -f "$file_path" || ! -r "$file_path" ]]; then
		display_error "Error: File '$file_path' does not exist or is not readable"
		exit 1
	fi

	# Check if file is empty
	if [[ ! -s "$file_path" ]]; then
		echo_blue "Debug: File is empty, no replacements possible"
		return 0
	fi

	# Check if prop_array is empty
	if [[ ${#prop_array[@]} -eq 0 ]]; then
		echo_blue "No extra properties provided for replacement in file: $file_path"
		return 0
	fi

	# Log the file being processed
	echo_blue "Processing extra properties: ${prop_array[*]} in file: $file_path"

	# Process each key:value pair
	for prop in "${prop_array[@]}"; do
		# Split key:value pair
		local key="${prop%%:*}"
		local value="${prop#*:}"

		# Validate key:value pair
		if [[ -z "$key" || -z "$value" ]]; then
			display_error "Error: Invalid key:value pair '$prop'"
			exit 1
		fi

		# Create pattern with @ delimiters
		local pattern="@${key}@"

		# Escape special characters for grep and sed, including dots
		local escaped_pattern
		escaped_pattern=$(printf '%s' "$pattern" | sed 's/[][\\^$.*]/\\&/g' | sed 's/\./\\./g')

		# Count occurrences of the pattern before replacement
		local count
		count=$(LC_ALL=C grep -o "$escaped_pattern" "$file_path" 2>grep_error.log | wc -l | tr -d '[:space:]')
		local grep_status=$?
		if [[ $grep_status -ne 0 && $grep_status -ne 1 ]]; then
			echo_blue "Debug: grep exit status: $grep_status"
			echo_blue "Debug: grep error output: $(cat grep_error.log)"
			display_error "Error: Failed to count occurrences of '$pattern' in '$file_path'"
			exit 1
		fi

		# Debug: Check if pattern exists
		if [[ $count -eq 0 ]]; then
			echo_blue "No occurrences of '$pattern' found in '$file_path'"
		else
			echo_blue "Found $count occurrences of '$pattern' in '$file_path'"
		fi

		# Replace all occurrences in file, use empty backup extension for macOS
		if ! LC_ALL=C sed -i '' "s|$escaped_pattern|$value|g" "$file_path" 2>sed_error.log; then
			echo_blue "Debug: sed error output: $(cat sed_error.log)"
			display_error "Error: Failed to replace '$pattern' in '$file_path'"
			exit 1
		fi
	done

	# Clean up temporary files
	rm -f grep_error.log sed_error.log
}


function create_zip_archive()
{
	local zip_file_name="$PLUGIN_NAME-iOS-v$PLUGIN_VERSION.zip"

	if [[ -e "$BUILD_DIR/release/$zip_file_name" ]]
	then
		display_warning "deleting existing $zip_file_name file..."
		rm $BUILD_DIR/release/$zip_file_name
	fi

	local tmp_directory=$(mktemp -d)

	display_status "preparing staging directory $tmp_directory"

	if [[ -d "$ADDON_DIR" ]]
	then
		mkdir -p $tmp_directory/addons/$PLUGIN_NAME
		cp -r $ADDON_DIR/* $tmp_directory/addons/$PLUGIN_NAME

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

		find "$tmp_directory" -type f \( -name '*.gd' -o -name '*.cfg' -o -name '*.gdip' \) | while IFS= read -r file; do
			echo_green "Editing: $file"

			# Escape variables to handle special characters
			ESCAPED_PLUGIN_NAME=$(printf '%s' "$PLUGIN_NAME" | sed 's/[\/&]/\\&/g')
			ESCAPED_PLUGIN_VERSION=$(printf '%s' "$PLUGIN_VERSION" | sed 's/[\/&]/\\&/g')
			ESCAPED_PLUGIN_NODE_NAME=$(printf '%s' "$PLUGIN_NODE_NAME" | sed 's/[\/&]/\\&/g')
			ESCAPED_PLUGIN_PACKAGE_NAME=$(printf '%s' "$PLUGIN_PACKAGE_NAME" | sed 's/[\/&]/\\&/g')
			ESCAPED_ANDROID_DEPENDENCIES=$(printf '%s' "$ANDROID_DEPENDENCIES" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_INITIALIZATION_METHOD=$(printf '%s' "$IOS_INITIALIZATION_METHOD" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_DEINITIALIZATION_METHOD=$(printf '%s' "$IOS_DEINITIALIZATION_METHOD" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_FRAMEWORKS=$(merge_string_array "${IOS_FRAMEWORKS[@]}" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_EMBEDDED_FRAMEWORKS=$(merge_string_array "${IOS_EMBEDDED_FRAMEWORKS[@]}" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_LINKER_FLAGS=$(merge_string_array "${IOS_LINKER_FLAGS[@]}" | sed 's/[\/&]/\\&/g')

			sed "${SED_INPLACE[@]}" -e "
				s|@pluginName@|$ESCAPED_PLUGIN_NAME|g;
				s|@pluginVersion@|$ESCAPED_PLUGIN_VERSION|g;
				s|@pluginNodeName@|$ESCAPED_PLUGIN_NODE_NAME|g;
				s|@pluginPackage@|$ESCAPED_PLUGIN_PACKAGE_NAME|g;
				s|@androidDependencies@|$ESCAPED_ANDROID_DEPENDENCIES|g;
				s|@iosInitializationMethod@|$ESCAPED_IOS_INITIALIZATION_METHOD|g;
				s|@iosDeinitializationMethod@|$ESCAPED_IOS_DEINITIALIZATION_METHOD|g;
				s|@iosFrameworks@|$ESCAPED_IOS_FRAMEWORKS|g;
				s|@iosEmbeddedFrameworks@|$ESCAPED_IOS_EMBEDDED_FRAMEWORKS|g;
				s|@iosLinkerFlags@|$ESCAPED_IOS_LINKER_FLAGS|g
			" "$file"

			replace_extra_properties $file ${EXTRA_PROPERTIES[@]}
		done
	else
		display_error "Error: '$ADDON_DIR' not found."
		exit 1
	fi

	mkdir -p $tmp_directory/ios/framework
	find $PODS_DIR -iname '*.xcframework' -type d -exec cp -r {} $tmp_directory/ios/framework \;

	cp $LIB_DIR/$PLUGIN_NAME.{release,debug}.a $tmp_directory/ios/plugins

	mkdir -p $DEST_DIR

	display_status "creating $zip_file_name file..."
	cd $tmp_directory; zip -yr $DEST_DIR/$zip_file_name ./*; cd -

	rm -rf $tmp_directory
}


while getopts "aAbcgG:hHipPt:z" option; do
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
		i)
			ignore_unsupported_godot_version=true
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
				display_error "Error: The argument for the -t option should be an integer. Found $OPTARG."
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
			display_error "Error: invalid option"
			echo
			display_help
			exit;;
	esac
done

if ! [[ " ${SUPPORTED_GODOT_VERSIONS[*]} " =~ [[:space:]]${GODOT_VERSION}[[:space:]] ]] && [[ "$do_build" == true ]]
then
	if [[ "$do_download_godot" == false ]]
	then
		display_warning "Warning: Godot version not specified. Will look for existing download."
	elif [[ "$ignore_unsupported_godot_version" == true ]]
	then
		display_warning "Warning: Godot version '$GODOT_VERSION' is not supported. Supported versions are [${SUPPORTED_GODOT_VERSIONS[*]}]."
	else
		display_error "Error: Godot version '$GODOT_VERSION' is not supported. Supported versions are [${SUPPORTED_GODOT_VERSIONS[*]}]."
		exit 1
	fi
fi

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
