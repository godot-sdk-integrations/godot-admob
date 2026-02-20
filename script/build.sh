#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/..)
COMMON_DIR=$ROOT_DIR/common
IOS_DIR=$ROOT_DIR/ios
RELEASE_DIR=$ROOT_DIR/release
DEMO_DIR=$ROOT_DIR/demo

COMMON_CONFIG_FILE=$COMMON_DIR/config/config.properties

PLUGIN_NODE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginNodeName)
PLUGIN_NAME="${PLUGIN_NODE_NAME}Plugin"
PLUGIN_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginVersion)
PLUGIN_MODULE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginModuleName)

ANDROID_ARCHIVE="$COMMON_DIR/build/archive/$PLUGIN_NAME-Android-v$PLUGIN_VERSION.zip"
IOS_ARCHIVE="$IOS_DIR/build/release/$PLUGIN_NAME-iOS-v$PLUGIN_VERSION.zip"
MULTI_PLATFORM_ARCHIVE="$RELEASE_DIR/$PLUGIN_NAME-Multi-v$PLUGIN_VERSION.zip"

do_clean_build=false
do_clean_all=false
do_build_android=false
do_build_ios=false
do_multiplatform_release=false
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
	echo_yellow "	$0 [-a|A|c|C|d|D|h|i|I|M|R|z|Z]"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	echo_yellow "	a	build plugin for the Android platform"
	echo_yellow "	A	build and create Android release archive"
	echo_yellow "	c	remove existing builds"
	echo_yellow "	C	remove existing builds and release archives"
	echo_yellow "	d	uninstall plugin from demo app"
	echo_yellow "	D	install plugin to demo app"
	echo_yellow "	h	display usage information"
	echo_yellow "	i	build plugin for the iOS platform"
	echo_yellow "	I	build and create iOS release archive (assumes Godot is already downloaded)"
	echo_yellow "	M	build and create multi-platform release archive (assumes Godot is already downloaded)"
	echo_yellow "	R	build and create all release archives (assumes Godot is already downloaded)"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Examples:"
	echo_yellow "	* clean existing build, do a release build for Android, and create archive"
	echo_yellow "		$> $0 -A"
	echo
	echo_yellow "	* clean existing build, do a release build for iOS, and create archive"
	echo_yellow "		$> $0 -I"
	echo
	echo_yellow "	* clean existing build, do a release build for Android and iOS, and create multi-platform archive"
	echo_yellow "		$> $0 -M"
	echo
	echo_yellow "	* clean existing build, do a release build for Android and iOS, and create all archives"
	echo_yellow "		$> $0 -R"
	echo
	echo_yellow "	* clean existing Android build, do a debug build for Android"
	echo_yellow "		$> $0 -a -- -cb"
	echo
	echo_yellow "	* display all options for the Android build"
	echo_yellow "		$> $0 -a -- -h"
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
	$SCRIPT_DIR/echocolor.sh -r "Error: $1"
}


function display_warning()
{
	echo_yellow "Warning: $1"
	echo
}


function run_android_build()
{
	local build_arguments="$1"

	display_step "Running Android build script with opts: $build_arguments"

	$SCRIPT_DIR/build_android.sh "$build_arguments"
}


function run_ios_build()
{
	local build_arguments="$1"

	display_step "Running iOS build script with opts: $build_arguments"

	$SCRIPT_DIR/build_ios.sh "$build_arguments"
}


while getopts "aAcCdDhiIMR" option; do
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
			do_clean_build=true
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
		M)
			do_multiplatform_release=true
			;;
		R)
			do_full_release=true
			;;
		\?)
			display_error "Invalid option $option"
			echo
			display_help
			exit;;
	esac
done


# Shift away the processed options
shift $((OPTIND - 1))


if [[ "$do_uninstall" == true ]]
then
	display_status "Uninstalling plugin from demo app"
	$SCRIPT_DIR/run_gradle_task.sh uninstall
fi

if [[ "$do_clean_build" == true ]]
then
	display_status "Cleaning builds"
	$SCRIPT_DIR/run_gradle_task.sh clean
fi

if [[ "$do_clean_all" == true ]]
then
	display_status "Cleaning all builds and release archives"

	$SCRIPT_DIR/run_gradle_task.sh clean

	if [[ -d "$RELEASE_DIR" ]]; then
		display_step "Removing $RELEASE_DIR"
		rm -rf $RELEASE_DIR
	else
		echo_yellow "'$RELEASE_DIR' does not exist. Skipping."
	fi
fi

if [[ "$do_build_android" == true ]]
then
	run_android_build "$@"
fi

if [[ "$do_build_ios" == true ]]
then
	run_ios_build "$@"
fi

if [[ "$do_multiplatform_release" == true ]]
then
	display_step "Creating Multi-platform release archive"
	$SCRIPT_DIR/run_gradle_task.sh "createMultiArchive"
fi

if [[ "$do_android_release" == true ]]
then
	run_android_build -R
fi

if [[ "$do_ios_release" == true ]]
then
	run_ios_build -R
fi

if [[ "$do_full_release" == true ]]
then
	display_status "Creating all release archives"
	$SCRIPT_DIR/run_gradle_task.sh "createArchives"
fi

if [[ "$do_install" == true ]]
then
	display_status "Installing plugin to demo app"
	$SCRIPT_DIR/run_gradle_task.sh "installToDemo"
fi
