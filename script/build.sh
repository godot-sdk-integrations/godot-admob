#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/..)
ANDROID_DIR=$ROOT_DIR/android
IOS_DIR=$ROOT_DIR/ios
DEST_DIR=$ROOT_DIR/release
DEMO_DIR=$ROOT_DIR/demo

COMMON_CONFIG_FILE=$ROOT_DIR/common/config.properties

PLUGIN_NODE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginNodeName)
PLUGIN_NAME="${PLUGIN_NODE_NAME}Plugin"
PLUGIN_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginVersion)
PLUGIN_MODULE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginModuleName)

ANDROID_ARCHIVE="$ANDROID_DIR/$PLUGIN_MODULE_NAME/build/dist/$PLUGIN_NAME-Android-v$PLUGIN_VERSION.zip"
IOS_ARCHIVE="$IOS_DIR/build/release/$PLUGIN_NAME-iOS-v$PLUGIN_VERSION.zip"
MULTI_PLATFORM_ARCHIVE="$DEST_DIR/$PLUGIN_NAME-Multi-v$PLUGIN_VERSION.zip"

do_clean_android=false
do_clean_all=false
do_build_android=false
do_build_ios=false
gradle_build_task="assembleDebug"
do_create_android_archive=false
do_create_multiplatform_archive=false
do_uninstall=false
do_install=false
do_android_release=false
do_ios_release=false
do_full_release=false


function display_help()
{
	echo
	$SCRIPT_DIR/echocolor.sh -y "The " -Y "$0 script" -y " builds the plugin and creates a zip file containing all"
	echo_yellow "libraries and configuration."
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Syntax:"
	echo_yellow "	$0 [-a|A|c|C|d|D|h|i|I|r|R|z|Z]"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	echo_yellow "	a	build plugin for the Android platform"
	echo_yellow "	A	build and create Android release archive"
	echo_yellow "	c	remove existing Android build"
	echo_yellow "	C	remove existing Android build, iOS build, and release archives"
	echo_yellow "	d	uninstall plugin from demo app"
	echo_yellow "	D	install plugin to demo app"
	echo_yellow "	h	display usage information"
	echo_yellow "	i	build plugin for the iOS platform"
	echo_yellow "	I	build and create iOS release archive (assumes Godot is already downloaded)"
	echo_yellow "	r	build Android plugin with release build variant"
	echo_yellow "	R	build and create all release archives (assumes Godot is already downloaded)"
	echo_yellow "	z	create Android zip archive"
	echo_yellow "	Z	create multi-platform zip archive (assumes Android and iOS archives have already "
	echo_yellow "		been created)"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Examples:"
	echo_yellow "	* clean existing build, do a release build for Android, and create archive"
	echo_yellow "		$> $0 -carz"
	echo
	echo_yellow "	* clean existing build, do a debug build for Android"
	echo_yellow "		$> $0 -ca"
	echo
	echo_yellow "	* clean existing iOS build, remove godot, and rebuild all"
	echo_yellow "		$> $0 -i -- -cgA"
	echo_yellow "		$> $0 -i -- -cgpGHPbz"
	echo
	echo_yellow "	* clean existing iOS build and rebuild"
	echo_yellow "		$> $0 -i -- -ca"
	echo
	echo_yellow "	* display all options for the iOS build"
	echo_yellow "		$> $0 -i -- -h"
	echo
	echo_yellow "	* clean existing build, do a debug build for Android, & then do an iOS build"
	echo_yellow "		$> $0 -cai -- -ca"
	echo
	echo_yellow "	* create multi-platform release archive."
	echo_yellow "	  (Requires both Android and iOS archives to have already been created)"
	echo_yellow "		$> $0 -Z"
	echo
}


function echo_yellow()
{
	$SCRIPT_DIR/echocolor.sh -y "$1"
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


function display_step()
{
	echo
	echo_green "* $1"
	echo
}


function display_error()
{
	$SCRIPT_DIR/echocolor.sh -r "$1"
}


function display_warning()
{
	echo_yellow "* $1"
	echo
}


function run_android_gradle_task()
{
	local gradle_task="$1"

	display_step "Running gradle task $gradle_task"

	pushd $ANDROID_DIR
	$ANDROID_DIR/gradlew $gradle_task
	popd
}


function run_ios_build()
{
	local build_arguments="$1"

	display_step "Running iOS build script with opts: $build_arguments"

	$SCRIPT_DIR/build_ios.sh "$build_arguments"
}


merge_zips() {
	local primary_zip="$1"
	local secondary_zip="$2"
	local output_zip="$3"

	# Check if all arguments are provided
	if [[ -z "$primary_zip" || -z "$secondary_zip" || -z "$output_zip" ]]; then
		display_error "Error: Usage: merge_zips <primary.zip> <secondary.zip> <output.zip>"
		return 1
	fi

	# Check if input files exist
	if [[ ! -f "$primary_zip" ]]; then
		display_error "Error: Primary zip file '$primary_zip' not found."
		return 1
	fi
	if [[ ! -f "$secondary_zip" ]]; then
		display_error "Error: Secondary zip file '$secondary_zip' not found."
		return 1
	fi

	# The cleanest way that works on both macOS and Linux is to use a temporary directory.
	local tmp_dir=$(mktemp -d)
	
	# Ensure the temporary directory is removed on exit (trap)
	trap "rm -rf \"$tmp_dir\"" EXIT

	# Unzip the SECONDARY (base) into tmp (silence output with -q)
	unzip -q "$secondary_zip" -d "$tmp_dir"

	# Unzip the PRIMARY (override) into tmp (use -o to force overwrite)
	# This ensures the first argument's files replace the second argument's files.
	unzip -qo "$primary_zip" -d "$tmp_dir"

	# Use standard 'zip' command inside the dir for safety
	(cd "$tmp_dir" && zip -rq "$output_zip" .)

	echo_green "Success: Merged '$primary_zip' and '$secondary_zip' into '$output_zip'"
}


function uninstall_plugin_from_demo()
{
	display_status "Uninstalling plugin from demo app"
	if [[ -d "$DEMO_DIR/addons/$PLUGIN_NAME" ]]; then
		echo_yellow "Removing $DEMO_DIR/addons/$PLUGIN_NAME"
		rm -rf $DEMO_DIR/addons/$PLUGIN_NAME
	fi

	if [[ -d "$DEMO_DIR/ios/plugins/$PLUGIN_NAME.debug.xcframework" ]]; then
		echo_yellow "Removing $DEMO_DIR/ios/plugins/$PLUGIN_NAME.debug.xcframework"
		rm -rf $DEMO_DIR/ios/plugins/$PLUGIN_NAME.debug.xcframework
	fi

	if [[ -d "$DEMO_DIR/ios/plugins/$PLUGIN_NAME.release.xcframework" ]]; then
		echo_yellow "Removing $DEMO_DIR/ios/plugins/$PLUGIN_NAME.release.xcframework"
		rm -rf $DEMO_DIR/ios/plugins/$PLUGIN_NAME.release.xcframework
	fi

	if [[ -f "$DEMO_DIR/ios/plugins/$PLUGIN_NAME.gdip" ]]; then
		echo_yellow "Removing $DEMO_DIR/ios/plugins/$PLUGIN_NAME.gdip"
		rm -rf $DEMO_DIR/ios/plugins/$PLUGIN_NAME.gdip
	fi
}


function install_plugin_to_demo()
{
	display_status "Installing plugin to demo app"
	if [[ -f "$IOS_ARCHIVE" ]]; then
		$SCRIPT_DIR/install.sh -t $DEMO_DIR -z $IOS_ARCHIVE
	else
		display_error "Error: Cannot install to demo. '$IOS_ARCHIVE' not found!"
	fi
}


while getopts "aAcCdDhiIrRzZ" option; do
	case $option in
		h)
			display_help
			exit;;
		a)
			do_build_android=true
			;;
		A)
			do_android_release=true
			;;
		c)
			do_clean_android=true
			;;
		C)
			do_clean_all=true
			;;
		d)
			do_uninstall=true
			;;
		D)
			do_install=true
			;;
		i)
			do_build_ios=true
			;;
		I)
			do_ios_release=true
			;;
		r)
			gradle_build_task="assembleRelease"
			;;
		R)
			do_full_release=true
			;;
		z)
			do_create_android_archive=true
			;;
		Z)
			do_create_multiplatform_archive=true
			;;
		\?)
			display_error "Error: invalid option"
			echo
			display_help
			exit;;
	esac
done


# Shift away the processed options
shift $((OPTIND - 1))


if [[ "$do_uninstall" == true ]]
then
	uninstall_plugin_from_demo
fi

if [[ "$do_clean_android" == true ]]
then
	display_status "Cleaning Android build"
	run_android_gradle_task clean
fi

if [[ "$do_clean_all" == true ]]
then
	display_status "Cleaning all builds and release archives"

	run_android_gradle_task clean

	run_ios_build -cp

	if [[ -d "$DEST_DIR" ]]; then
		display_step "Removing $DEST_DIR"
		rm -rf $DEST_DIR
	else
		echo_yellow "'$DEST_DIR' does not exist. Skipping."
	fi
fi

if [[ "$do_build_android" == true ]]
then
	display_status "Building Android"
	run_android_gradle_task $gradle_build_task
fi

if [[ "$do_create_android_archive" == true ]]
then
	display_status "Creating Android archive"
	run_android_gradle_task "packageDistribution"
fi

if [[ "$do_build_ios" == true ]]
then
	run_ios_build "$@"
fi

if [[ "$do_create_multiplatform_archive" == true ]]
then
	mkdir -p $DEST_DIR

	display_step "Creating Multi-platform release archive"
	merge_zips "$ANDROID_ARCHIVE" "$IOS_ARCHIVE" "$MULTI_PLATFORM_ARCHIVE"
fi

if [[ "$do_android_release" == true ]]
then
	display_status "Creating Android release archive"
	run_android_gradle_task "assembleDebug"
	run_android_gradle_task "assembleRelease"
	run_android_gradle_task "packageDistribution"

	mkdir -p $DEST_DIR

	display_step "Copying Android release archive to $DEST_DIR"
	cp $ANDROID_ARCHIVE $DEST_DIR
fi

if [[ "$do_ios_release" == true ]]
then
	display_status "Creating iOS release archive"
	run_ios_build -cHpPbz

	mkdir -p $DEST_DIR

	display_step "Copying iOS release archive to $DEST_DIR"
	cp $IOS_ARCHIVE $DEST_DIR
fi

if [[ "$do_full_release" == true ]]
then
	display_status "Creating Android release archive"
	run_android_gradle_task "assembleDebug"
	run_android_gradle_task "assembleRelease"
	run_android_gradle_task "packageDistribution"

	display_status "Creating iOS release archive"
	run_ios_build -cHpPbz

	mkdir -p $DEST_DIR

	display_status "Creating Multi-platform release archive"
	merge_zips "$ANDROID_ARCHIVE" "$IOS_ARCHIVE" "$MULTI_PLATFORM_ARCHIVE"

	display_status "Copying platform release archives to release directory"

	display_step "Copying Android release archive to $DEST_DIR"
	cp $ANDROID_ARCHIVE $DEST_DIR

	display_step "Copying iOS release archive to $DEST_DIR"
	cp $IOS_ARCHIVE $DEST_DIR
fi

if [[ "$do_install" == true ]]
then
	install_plugin_to_demo
fi
