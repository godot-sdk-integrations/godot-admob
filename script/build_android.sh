#!/bin/bash
#
# © 2026-present https://github.com/cengiz-pz
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/..)
COMMON_DIR=$ROOT_DIR/common
RELEASE_DIR=$ROOT_DIR/release
DEMO_DIR=$ROOT_DIR/demo

COMMON_CONFIG_FILE=$COMMON_DIR/config/config.properties

PLUGIN_NODE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginNodeName)
PLUGIN_NAME="${PLUGIN_NODE_NAME}Plugin"
PLUGIN_VERSION=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginVersion)
PLUGIN_MODULE_NAME=$($SCRIPT_DIR/get_config_property.sh -f $COMMON_CONFIG_FILE pluginModuleName)

ANDROID_ARCHIVE="$COMMON_DIR/build/archive/$PLUGIN_NAME-Android-v$PLUGIN_VERSION.zip"
MULTI_PLATFORM_ARCHIVE="$RELEASE_DIR/$PLUGIN_NAME-Multi-v$PLUGIN_VERSION.zip"

do_clean_build=false
do_build=false
gradle_build_task="buildAndroidDebug"
do_create_archive=false
do_uninstall=false
do_install=false


function display_help()
{
	echo
	$SCRIPT_DIR/echocolor.sh -y "The " -Y "$0 script" -y " builds the plugin and creates a zip file containing all"
	echo_yellow "libraries and configuration."
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Syntax:"
	echo_yellow "	$0 [-b|c|d|D|h|r|R]"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	echo_yellow "	b	build plugin for the Android platform"
	echo_yellow "	c	remove existing Android build"
	echo_yellow "	d	uninstall Android plugin from demo app"
	echo_yellow "	D	install Android plugin to demo app"
	echo_yellow "	h	display usage information"
	echo_yellow "	r	build Android plugin with release build variant"
	echo_yellow "	R	create Android release archive"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Examples:"
	echo_yellow "	* clean existing build, do a release build for Android, and create archive"
	echo_yellow "		$> $0 -cbrR"
	echo
	echo_yellow "	* clean existing build, do a debug build for Android"
	echo_yellow "		$> $0 -cb"
	echo
	echo_yellow "	* uninstall Android plugin from demo app"
	echo_yellow "		$> $0 -d"
	echo
	echo_yellow "	* install Android plugin to demo app"
	echo_yellow "		$> $0 -D"
	echo
	echo_yellow "	* clean, build, and create Android release archive"
	echo_yellow "		$> $0 -R"
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


while getopts "bcdDhrR" option; do
	case $option in
		h)
			display_help
			exit;;
		b)
			do_build=true
			;;
		c)
			do_clean_build=true
			;;
		d)
			do_uninstall=true
			;;
		D)
			do_install=true
			;;
		r)
			gradle_build_task="buildAndroidRelease"
			;;
		R)
			do_create_archive=true
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
	display_status "Installing Android plugin to demo app"
	$SCRIPT_DIR/run_gradle_task.sh "uninstallAndroid"
fi

if [[ "$do_clean_build" == true ]]
then
	display_status "Cleaning Android build"
	$SCRIPT_DIR/run_gradle_task.sh ":android:clean"
fi

if [[ "$do_build" == true ]]
then
	display_status "Building Android"
	$SCRIPT_DIR/run_gradle_task.sh $gradle_build_task
fi

if [[ "$do_create_archive" == true ]]
then
	display_status "Creating Android archive"
	$SCRIPT_DIR/run_gradle_task.sh "createAndroidArchive"
fi

if [[ "$do_install" == true ]]
then
	display_status "Installing Android plugin to demo app"
	$SCRIPT_DIR/run_gradle_task.sh "installToDemoAndroid"
fi
