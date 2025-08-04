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
CONFIG_DIR=$IOS_DIR/config
PODS_DIR=$IOS_DIR/Pods
BUILD_DIR=$IOS_DIR/build
DEST_DIR=$BUILD_DIR/release
FRAMEWORK_DIR=$BUILD_DIR/framework
LIB_DIR=$BUILD_DIR/lib

PLUGIN_NODE_TYPE=$($SCRIPT_DIR/get_config_property.sh plugin_node_name)
PLUGIN_NAME="${PLUGIN_NODE_TYPE}Plugin"
PLUGIN_VERSION=''
PLUGIN_PACKAGE_NAME=$($SCRIPT_DIR/get_gradle_property.sh pluginPackageName $ANDROID_DIR/config.gradle.kts)
ANDROID_DEPENDENCIES=$($SCRIPT_DIR/get_android_dependencies.sh)
IOS_FRAMEWORKS=()
while IFS= read -r line; do
	IOS_FRAMEWORKS+=("$line")
done < <($SCRIPT_DIR/get_config_property.sh -qa frameworks)
IOS_EMBEDDED_FRAMEWORKS=()
while IFS= read -r line; do
	IOS_EMBEDDED_FRAMEWORKS+=("$line")
done < <($SCRIPT_DIR/get_config_property.sh -qa embedded_frameworks)
IOS_LINKER_FLAGS=()
while IFS= read -r line; do
	IOS_LINKER_FLAGS+=("$line")
done < <($SCRIPT_DIR/get_config_property.sh -qa flags)
SUPPORTED_GODOT_VERSIONS=()
while IFS= read -r line; do
	SUPPORTED_GODOT_VERSIONS+=($line)
done < <($SCRIPT_DIR/get_config_property.sh -a valid_godot_versions)
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
	echo_yellow "	$0 [-a|A <godot version>|c|g|G <godot version>|h|H|i|p|P|t <timeout>|z <version>]"
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Options:"
	echo_yellow "	a	generate godot headers and build plugin"
	echo_yellow "	A	download specified godot version, generate godot headers, and"
	echo_yellow "	 	build plugin"
	echo_yellow "	b	build plugin"
	echo_yellow "	c	remove any existing plugin build"
	echo_yellow "	g	remove godot directory"
	echo_yellow "	G	download the godot version specified in the option argument"
	echo_yellow "	 	into godot directory"
	echo_yellow "	h	display usage information"
	echo_yellow "	H	generate godot headers"
	echo_yellow "	i	ignore if an unsupported godot version selected and continue"
	echo_yellow "	p	remove pods and pod repo trunk"
	echo_yellow "	P	install pods"
	echo_yellow "	t	change timeout value for godot build"
	echo_yellow "	z	create zip archive with given version added to the file name"
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Examples:"
	echo_yellow "	* clean existing build, remove godot, and rebuild all"
	echo_yellow "		$> $0 -cgA 4.2"
	echo_yellow "		$> $0 -cgpG 4.2 -HPbz 1.0"
	echo
	echo_yellow "	* clean existing build, remove pods and pod repo trunk, and rebuild plugin"
	echo_yellow "		$> $0 -cpPb"
	echo
	echo_yellow "	* clean existing build and rebuild plugin"
	echo_yellow "		$> $0 -ca"
	echo
	echo_yellow "	* clean existing build and rebuild plugin with custom plugin version"
	echo_yellow "		$> $0 -cHbz 1.0"
	echo
	echo_yellow "	* clean existing build and rebuild plugin with custom build timeout"
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
	if [[ $# -eq 0 ]]
	then
		display_error "Error: Please provide the Godot version as an option argument for -G option."
		exit 1
	fi

	if [[ -d "$GODOT_DIR" ]]
	then
		display_error "Error: $GODOT_DIR directory already exists. Won't download."
		exit 1
	fi

	SELECTED_GODOT_VERSION=$1
	display_status "downloading godot version $SELECTED_GODOT_VERSION..."

	$SCRIPT_DIR/fetch_git_repo.sh -t ${SELECTED_GODOT_VERSION}-stable https://github.com/godotengine/godot.git $GODOT_DIR

	if [[ -d "$GODOT_DIR" ]]
	then
		echo "$SELECTED_GODOT_VERSION" > $GODOT_DIR/GODOT_VERSION
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

	$SCRIPT_DIR/run_with_timeout.sh -t $BUILD_TIMEOUT -c "scons platform=ios target=template_release" -d ./godot || true

	display_status "terminated godot build after $BUILD_TIMEOUT seconds..."
}


function generate_static_library()
{
	if [[ ! -f "$GODOT_DIR/GODOT_VERSION" ]]
	then
		display_error "Error: godot wasn't downloaded properly. Can't generate static library."
		exit 1
	fi

	GODOT_VERSION=$(cat $GODOT_DIR/GODOT_VERSION)

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
	pod install --repo-update || true
}


function build_plugin()
{
	if [[ ! -f "$GODOT_DIR/GODOT_VERSION" ]]
	then
		display_error "Error: godot wasn't downloaded properly. Can't build plugin."
		exit 1
	fi

	GODOT_VERSION=$(cat $GODOT_DIR/GODOT_VERSION)

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

	cp "$CONFIG_DIR"/*.gdip "$DEST_DIR"
}


function merge_string_array() {
	local arr=("$@")	# Accept array as input
	printf "%s" "${arr[0]}"
	for ((i=1; i<${#arr[@]}; i++)); do
		printf ", %s" "${arr[i]}"
	done
}


function create_zip_archive()
{
	if [[ ! -f "$GODOT_DIR/GODOT_VERSION" ]]
	then
		display_error "Error: godot wasn't downloaded properly. Can't create zip archive."
		exit 1
	fi

	GODOT_VERSION=$(cat $GODOT_DIR/GODOT_VERSION)

	if [[ -z $PLUGIN_VERSION ]]
	then
		godot_version_suffix="v$GODOT_VERSION"
	else
		godot_version_suffix="v$PLUGIN_VERSION"
	fi

	file_name="$PLUGIN_NAME-iOS-$godot_version_suffix.zip"

	if [[ -e "$BUILD_DIR/release/$file_name" ]]
	then
		display_warning "deleting existing $file_name file..."
		rm $BUILD_DIR/release/$file_name
	fi

	tmp_directory=$BUILD_DIR/.tmp_zip

	if [[ -d "$tmp_directory" ]]
	then
		display_status "removing existing staging directory $tmp_directory"
		rm -r $tmp_directory
	fi

	display_status "preparing staging directory $tmp_directory"

	if [[ -d "$ADDON_DIR" ]]
	then
		mkdir -p $tmp_directory/addons/$PLUGIN_NAME
		cp -r $ADDON_DIR/* $tmp_directory/addons/$PLUGIN_NAME

		# Detect OS
		if [[ "$OSTYPE" == "darwin"* ]]; then
			# macOS: use -i ''
			SED_INPLACE=(-i '')
		else
			# Linux: use -i with no backup suffix
			SED_INPLACE=(-i)
		fi

		for file in "$tmp_directory/addons/$PLUGIN_NAME"/*.{gd,cfg}; do
			[[ -e "$file" ]] || continue
			echo_blue "Editing: $file"

			# Escape variables to handle special characters
			ESCAPED_PLUGIN_NAME=$(printf '%s' "$PLUGIN_NAME" | sed 's/[\/&]/\\&/g')
			ESCAPED_PLUGIN_VERSION=$(printf '%s' "$PLUGIN_VERSION" | sed 's/[\/&]/\\&/g')
			ESCAPED_PLUGIN_NODE_TYPE=$(printf '%s' "$PLUGIN_NODE_TYPE" | sed 's/[\/&]/\\&/g')
			ESCAPED_PLUGIN_PACKAGE_NAME=$(printf '%s' "$PLUGIN_PACKAGE_NAME" | sed 's/[\/&]/\\&/g')
			ESCAPED_ANDROID_DEPENDENCIES=$(printf '%s' "$ANDROID_DEPENDENCIES" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_FRAMEWORKS=$(merge_string_array "${IOS_FRAMEWORKS[@]}" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_EMBEDDED_FRAMEWORKS=$(merge_string_array "${IOS_EMBEDDED_FRAMEWORKS[@]}" | sed 's/[\/&]/\\&/g')
			ESCAPED_IOS_LINKER_FLAGS=$(merge_string_array "${IOS_LINKER_FLAGS[@]}" | sed 's/[\/&]/\\&/g')

			sed "${SED_INPLACE[@]}" -e "
				s|@pluginName@|$ESCAPED_PLUGIN_NAME|g;
				s|@pluginVersion@|$ESCAPED_PLUGIN_VERSION|g;
				s|@pluginNodeName@|$ESCAPED_PLUGIN_NODE_TYPE|g;
				s|@pluginPackage@|$ESCAPED_PLUGIN_PACKAGE_NAME|g;
				s|@pluginDependencies@|$ESCAPED_ANDROID_DEPENDENCIES|g;
				s|@iosFrameworks@|$ESCAPED_IOS_FRAMEWORKS|g;
				s|@iosEmbeddedFrameworks@|$ESCAPED_IOS_EMBEDDED_FRAMEWORKS|g;
				s|@iosLinkerFlags@|$ESCAPED_IOS_LINKER_FLAGS|g
			" "$file"
		done
	else
		display_error "Error: '$ADDON_DIR' not found."
		exit 1
	fi

	mkdir -p $tmp_directory/ios/framework
	find $PODS_DIR -iname '*.xcframework' -type d -exec cp -r {} $tmp_directory/ios/framework \;

	mkdir -p $tmp_directory/ios/plugins
	cp $CONFIG_DIR/*.gdip $tmp_directory/ios/plugins
	cp $LIB_DIR/$PLUGIN_NAME.{release,debug}.a $tmp_directory/ios/plugins

	mkdir -p $DEST_DIR

	display_status "creating $file_name file..."
	cd $tmp_directory; zip -yr $DEST_DIR/$file_name ./*; cd -

	rm -rf $tmp_directory
}


while getopts "aA:bcgG:hHipPt:z:" option; do
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
			GODOT_VERSION=$OPTARG
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
			GODOT_VERSION=$OPTARG
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
			if ! [[ -z $OPTARG ]]
			then
				PLUGIN_VERSION=$OPTARG
			fi
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
	download_godot $GODOT_VERSION
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
