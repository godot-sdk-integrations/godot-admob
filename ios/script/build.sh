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
COMMON_DIR=$ROOT_DIR/common
PODS_DIR=$IOS_DIR/Pods
BUILD_DIR=$IOS_DIR/build
DEST_DIR=$BUILD_DIR/release
FRAMEWORK_DIR=$BUILD_DIR/framework
LIB_DIR=$BUILD_DIR/lib
IOS_CONFIG_FILE=$IOS_CONFIG_DIR/config.properties
COMMON_CONFIG_FILE=$COMMON_DIR/config.properties
MEDIATION_CONFIG_FILE=$COMMON_DIR/mediation.properties

PLUGIN_NODE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginNodeName)
PLUGIN_NAME="${PLUGIN_NODE_NAME}Plugin"
PLUGIN_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginVersion)
IOS_INITIALIZATION_METHOD=$($SCRIPT_DIR/get_config_property.sh -f $IOS_CONFIG_FILE initialization_method)
IOS_DEINITIALIZATION_METHOD=$($SCRIPT_DIR/get_config_property.sh -f $IOS_CONFIG_FILE deinitialization_method)
IOS_PLATFORM_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $IOS_CONFIG_FILE platform_version)
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


function generate_dynamic_library()
{
	if [[ ! -f "$GODOT_DIR/GODOT_VERSION" ]]
	then
		display_error "Error: godot wasn't downloaded properly. Can't generate dynamic library."
		exit 1
	fi

	local target_type="$1"
	local lib_directory="$2"

	display_status "generating dynamic libraries for $PLUGIN_NAME with target type $target_type..."

	pushd $IOS_DIR

	# ARM64 Device
	scons target=$target_type arch=arm64 ios_sdk=iphoneos target_path=$lib_directory/ target_name=$PLUGIN_NAME version=$GODOT_VERSION

	# ARM64 Simulator
	scons target=$target_type arch=arm64 ios_sdk=iphonesimulator simulator=yes target_path=$lib_directory/ target_name=$PLUGIN_NAME version=$GODOT_VERSION

	# x86_64 Simulator
	scons target=$target_type arch=x86_64 ios_sdk=iphonesimulator simulator=yes target_path=$lib_directory/ target_name=$PLUGIN_NAME version=$GODOT_VERSION

	popd

	echo_green "dynamic libraries created in: $lib_directory"
}


function install_pods()
{
	display_status "installing pods..."
	pod install --repo-update --project-directory=$IOS_DIR/ || true
}


function create_xcframework()
{
	local target_type="$1"
	local lib_directory="$2"

	display_status "creating xcframework for $target_type..."

	local device_dylib="$lib_directory/lib$PLUGIN_NAME.arm64-ios.$target_type.dylib"
	local sim_arm64_dylib="$lib_directory/lib$PLUGIN_NAME.arm64-simulator.$target_type.dylib"
	local sim_x86_64_dylib="$lib_directory/lib$PLUGIN_NAME.x86_64-simulator.$target_type.dylib"
	local sim_universal_dylib="$lib_directory/lib$PLUGIN_NAME.simulator.$target_type.dylib"

	# Create universal simulator binary
	display_status "creating universal simulator binary..."
	lipo -create "$sim_arm64_dylib" "$sim_x86_64_dylib" -output "$sim_universal_dylib"

	# Create framework structure for device
	local device_framework_dir="$lib_directory/device/$PLUGIN_NAME.framework"
	mkdir -p "$device_framework_dir"
	cp "$device_dylib" "$device_framework_dir/$PLUGIN_NAME"

	# Create framework structure for simulator
	local sim_framework_dir="$lib_directory/simulator/$PLUGIN_NAME.framework"
	mkdir -p "$sim_framework_dir"
	cp "$sim_universal_dylib" "$sim_framework_dir/$PLUGIN_NAME"

	# Create Info.plist for both frameworks
	cat > "$device_framework_dir/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>$PLUGIN_NAME</string>
	<key>CFBundleIdentifier</key>
	<string>org.godotengine.$PLUGIN_NAME</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$PLUGIN_NAME</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>MinimumOSVersion</key>
	<string>$IOS_PLATFORM_VERSION</string>
</dict>
</plist>
EOF

	cp "$device_framework_dir/Info.plist" "$sim_framework_dir/Info.plist"

	# Create xcframework
	local xcframework_name="$PLUGIN_NAME.$target_type.xcframework"
	rm -rf "$FRAMEWORK_DIR/$xcframework_name"

	xcodebuild -create-xcframework \
		-framework "$device_framework_dir" \
		-framework "$sim_framework_dir" \
		-output "$FRAMEWORK_DIR/$xcframework_name"

	echo_green "xcframework created: $FRAMEWORK_DIR/$xcframework_name"
}

function build_plugin()
{
	if [[ ! -d "$PODS_DIR" ]]
	then
		display_error "Error: Pods directory does not exist. Run 'pod install' first."
		exit 1
	fi

	if [[ ! -d "$GODOT_DIR" ]]
	then
		display_error "Error: $GODOT_DIR directory does not exist. Can't build plugin."
		exit 1
	fi

	if [[ ! -f "$GODOT_DIR/GODOT_VERSION" ]]
	then
		display_error "Error: godot wasn't downloaded properly. Can't build plugin."
		exit 1
	fi

	# Clear target directories
	rm -rf "$DEST_DIR"
	rm -rf "$LIB_DIR"
	rm -rf "$FRAMEWORK_DIR"

	# Create target directories
	mkdir -p "$DEST_DIR"
	mkdir -p "$LIB_DIR"
	mkdir -p "$FRAMEWORK_DIR"

	display_status "building plugin library with godot version $GODOT_VERSION ..."

	# Compile library
	generate_dynamic_library release $LIB_DIR
	generate_dynamic_library release_debug $LIB_DIR

	# Create xcframeworks
	create_xcframework release $LIB_DIR
	create_xcframework release_debug $LIB_DIR

	# Rename release_debug to debug
	mv "$FRAMEWORK_DIR/$PLUGIN_NAME.release_debug.xcframework" "$FRAMEWORK_DIR/$PLUGIN_NAME.debug.xcframework"

	# Copy xcframeworks to destination
	cp -r "$FRAMEWORK_DIR/$PLUGIN_NAME.release.xcframework" "$DEST_DIR/"
	cp -r "$FRAMEWORK_DIR/$PLUGIN_NAME.debug.xcframework" "$DEST_DIR/"

	cp "$IOS_CONFIG_DIR"/*.gdip "$DEST_DIR"
}


function merge_string_array()
{
	local arr=("$@")	# Accept array as input
	printf "%s" "${arr[0]}"
	for ((i=1; i<${#arr[@]}; i++)); do
		printf ", %s" "${arr[i]}"
	done
}


function replace_extra_properties()
{
	local file_path="$1"
	shift
	local prop_array=("$@")

	# Check if file exists and is not empty
	if [[ ! -s "$file_path" ]]; then
		display_error "Error: File '$file_path' does not exist or is empty, skipping replacements"
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


function replace_mediation_properties()
{
	local file_path="$1"
	local mediation_config_file="$2"

	# Check if mediation config file exists
	if [[ ! -f "$mediation_config_file" ]]; then
		display_error "Error: Mediation config file '$mediation_config_file' not found."
		exit 1
	fi

	# Check if file exists and is not empty
	if [[ ! -s "$file_path" ]]; then
		echo_blue "File '$file_path' does not exist or is empty, skipping mediation replacements"
		return 0
	fi

	# Dynamically extract network tags from mediation.properties
	# Ignore comments and empty lines, match lines with network.property=value
	local networks=($(grep -v '^#' "$mediation_config_file" | grep -E '^[a-z]+(\.[a-zA-Z]+)*=.*' | sed 's/\..*//' | sort -u))

	local network
	local deps=()
	local deps_joined=""
	local repo
	local adapter
	local extras
	local pod
	local pod_ver
	local skad_ids=()
	local skad_joined=""
	local esc_deps
	local esc_repo
	local esc_adapter
	local esc_pod
	local esc_pod_ver
	local esc_skad_ids

	for network in "${networks[@]}"; do
		repo=$($SCRIPT_DIR/get_config_property.sh -f "$mediation_config_file" "${network}.mavenRepo")
		android_adapter=$($SCRIPT_DIR/get_config_property.sh -f "$mediation_config_file" "${network}.androidAdapterClass")
		ios_adapter=$($SCRIPT_DIR/get_config_property.sh -f "$mediation_config_file" "${network}.iosAdapterClass")
		pod=$($SCRIPT_DIR/get_config_property.sh -f "$mediation_config_file" "${network}.pod")
		pod_ver=$($SCRIPT_DIR/get_config_property.sh -f "$mediation_config_file" "${network}.podVersion")

		# Check for missing required properties
		if [[ -z "$pod" ]]; then
			display_error "Error: Missing required property '${network}.pod' in '$mediation_config_file'"
			exit 1
		fi
		if [[ -z "$pod_ver" ]]; then
			display_error "Error: Missing required property '${network}.podVersion' in '$mediation_config_file'"
			exit 1
		fi
		
		# Fetch Android dependencies as comma-separated array and quote each
		deps=()
		while IFS= read -r id; do
			if [[ -n "$id" ]]; then
				deps+=("$id")
			fi
		done < <($SCRIPT_DIR/get_config_property.sh -qa -f "$mediation_config_file" "${network}.dependencies")

		# Join quoted deps with commas
		if [[ ${#deps[@]} -gt 0 ]]; then
			IFS=', '
			deps_joined="${deps[*]}"
			unset IFS
		else
			deps_joined=""
		fi

		# Check for missing or empty dependencies property
		if [[ -z "$deps_joined" ]]; then
			display_error "Error: Missing required property '${network}.dependencies' in '$mediation_config_file' or it is empty. At least one entry is required."
			exit 1
		fi
		
		# Fetch SK Ad Network IDs as comma-separated array and quote each
		skad_ids=()
		while IFS= read -r id; do
			if [[ -n "$id" ]]; then
				skad_ids+=("$id")
			fi
		done < <($SCRIPT_DIR/get_config_property.sh -qa -f "$mediation_config_file" "${network}.skAdNetworkIds")

		# Join quoted IDs with commas
		if [[ ${#skad_ids[@]} -gt 0 ]]; then
			IFS=', '
			skad_joined="${skad_ids[*]}"
			unset IFS
		else
			skad_joined=""
		fi

		# Check for missing or empty SK Ad Network IDs
		if [[ -z "$skad_joined" ]]; then
			display_error "Error: Missing required property '${network}.skAdNetworkIds' in '$mediation_config_file' or it is empty. At least one entry is required."
			exit 1
		fi

		# Escape values for sed
		esc_deps=$(printf '%s\n' "$deps_joined" | sed 's/[\/&]/\\&/g')
		esc_repo=$(printf '%s\n' "$repo" | sed 's/[\/&]/\\&/g')
		esc_android_adapter=$(printf '%s\n' "$android_adapter" | sed 's/[\/&]/\\&/g')
		esc_ios_adapter=$(printf '%s\n' "$ios_adapter" | sed 's/[\/&]/\\&/g')
		esc_pod=$(printf '%s\n' "$pod" | sed 's/[\/&]/\\&/g')
		esc_pod_ver=$(printf '%s\n' "$pod_ver" | sed 's/[\/&]/\\&/g')
		esc_skad_ids=$(printf '%s\n' "$skad_joined" | sed 's/[\/&]/\\&/g')

		# Perform replacements with sed
		sed "${SED_INPLACE[@]}" \
			-e "s|@${network}Dependencies@|${esc_deps}|g" \
			-e "s|@${network}MavenRepo@|${esc_repo}|g" \
			-e "s|@${network}AndroidAdapterClass@|${esc_android_adapter}|g" \
			-e "s|@${network}IosAdapterClass@|${esc_ios_adapter}|g" \
			-e "s|@${network}Pod@|${esc_pod}|g" \
			-e "s|@${network}PodVersion@|${esc_pod_ver}|g" \
			-e "s|@${network}SkAdNetworkIds@|${esc_skad_ids}|g" \
			"$file_path"
	done
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
			ESCAPED_IOS_PLATFORM_VERSION=$(printf '%s' "$IOS_PLATFORM_VERSION" | sed 's/[\/&]/\\&/g')
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
				s|@iosPlatformVersion@|$ESCAPED_IOS_PLATFORM_VERSION|g;
				s|@iosFrameworks@|$ESCAPED_IOS_FRAMEWORKS|g;
				s|@iosEmbeddedFrameworks@|$ESCAPED_IOS_EMBEDDED_FRAMEWORKS|g;
				s|@iosLinkerFlags@|$ESCAPED_IOS_LINKER_FLAGS|g
			" "$file"

			# Mediation replacements for MediationNetwork.gd
			if echo "$file" | grep -q "MediationNetwork.gd$"; then
				replace_mediation_properties "$file" "$MEDIATION_CONFIG_FILE"
			fi

			replace_extra_properties "$file" "${EXTRA_PROPERTIES[@]}"
		done
	else
		display_error "Error: '$ADDON_DIR' not found."
		exit 1
	fi

	mkdir -p $tmp_directory/ios/framework
	find $PODS_DIR -iname '*.xcframework' -type d -exec cp -r {} $tmp_directory/ios/framework \;

	# Copy plugin xcframeworks
	cp -r $FRAMEWORK_DIR/$PLUGIN_NAME.release.xcframework $tmp_directory/ios/plugins/
	cp -r $FRAMEWORK_DIR/$PLUGIN_NAME.debug.xcframework $tmp_directory/ios/plugins/

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
