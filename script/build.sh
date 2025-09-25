#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -e
trap "sleep 1; echo" EXIT

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/..)

DEST_DIR=$ROOT_DIR/release
DEMO_DIR=$ROOT_DIR/demo

COMMON_CONFIG_FILE=$ROOT_DIR/common/config.properties

PLUGIN_NODE_NAME=$($ROOT_DIR/ios/script/get_config_property.sh -f $COMMON_CONFIG_FILE pluginNodeName)
PLUGIN_NAME="${PLUGIN_NODE_NAME}Plugin"
PLUGIN_VERSION=$($ROOT_DIR/ios/script/get_config_property.sh -f $COMMON_CONFIG_FILE pluginVersion)

do_clean=false
do_build_android=false
do_build_ios=false
gradle_build_task="assembleDebug"
do_create_archive=false
do_create_multiplatform_archive=false
do_full_release=false


function display_help()
{
	echo
	$SCRIPT_DIR/echocolor.sh -y "The " -Y "$0 script" -y " builds the plugin and creates a zip file containing all"
	echo_yellow "libraries and configuration."
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Syntax:"
	echo_yellow "	$0 [-a|c|h|i|r|R|z|Z]"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	echo_yellow "	a	build plugin for the Android platform"
	echo_yellow "	c	remove any existing plugin build"
	echo_yellow "	h	display usage information"
	echo_yellow "	i	build plugin for the iOS platform"
	echo_yellow "	r	build Android plugin with release build variant"
	echo_yellow "	R	build and create all release archives (assumes Godot is already downloaded)"
	echo_yellow "	z	create Android zip archive"
	echo_yellow "	Z	create multi-platform zip archive"
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
	echo_yellow "	(Requires both plugin variants to have been installed in demo app.)"
	echo_yellow "		$> $0 -Z"
	echo
}


function echo_yellow()
{
	$ROOT_DIR/script/echocolor.sh -y "$1"
}


function echo_green()
{
	$ROOT_DIR/script/echocolor.sh -g "$1"
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

	pushd android
	$ROOT_DIR/android/gradlew $gradle_task
	popd
}


function run_ios_build()
{
	local build_arguments="$1"

	$ROOT_DIR/ios/script/build.sh "$build_arguments"
}


function create_multi_platform_archive()
{
	if [[ -d "$DEMO_DIR" ]]
	then
		if [[ ! -d "$DEST_DIR" ]]
		then
			mkdir -p $DEST_DIR
		fi

		local zip_file_name="$PLUGIN_NAME-Multi-v$PLUGIN_VERSION.zip"

		if [[ -e "$DEST_DIR/$zip_file_name" ]]
		then
			display_warning "deleting existing $zip_file_name file..."
			rm $DEST_DIR/$zip_file_name
		fi

		local tmp_directory=$(mktemp -d)

		display_step "preparing staging directory $tmp_directory..."

		mkdir -p $tmp_directory/addons/$PLUGIN_NAME
		cp -r $DEMO_DIR/addons/$PLUGIN_NAME/* $tmp_directory/addons/$PLUGIN_NAME

		mkdir -p $tmp_directory/ios/plugins
		cp -r $DEMO_DIR/ios/plugins/* $tmp_directory/ios/plugins

		mkdir -p $tmp_directory/ios/framework
		cp -r $DEMO_DIR/ios/framework/* $tmp_directory/ios/framework

		display_step "creating $zip_file_name file in $DEST_DIR..."
		pushd $tmp_directory > /dev/null
		zip -yr $DEST_DIR/$zip_file_name ./*
		popd > /dev/null

		echo ; display_warning "removing staging directory $tmp_directory..."
		rm -rf $tmp_directory
	else
		display_error "Error: '$DEMO_DIR' not found."
		exit 1
	fi
}


while getopts "achirRzZ" option; do
	case $option in
		h)
			display_help
			exit;;
		a)
			do_build_android=true
			;;
		c)
			do_clean=true
			;;
		i)
			do_build_ios=true
			;;
		r)
			gradle_build_task="assembleRelease"
			;;
		R)
			do_full_release=true
			;;
		z)
			do_create_archive=true
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


if [[ "$do_clean" == true ]]
then
	display_status "Cleaning build"
	run_android_gradle_task clean
fi

if [[ "$do_build_android" == true ]]
then
	display_status "Building Android"
	run_android_gradle_task $gradle_build_task
fi

if [[ "$do_create_archive" == true ]]
then
	display_status "Creating Android archive"
	run_android_gradle_task "packageDistribution"
fi

if [[ "$do_build_ios" == true ]]
then
	display_status "Running iOS build script with args: $@"
	run_ios_build "$@"
fi

if [[ "$do_create_multiplatform_archive" == true ]]
then
	display_status "Creating multi-platform archive"
	create_multi_platform_archive
fi

if [[ "$do_full_release" == true ]]
then
	display_status "Creating all archives"
	run_android_gradle_task "assembleDebug"
	run_android_gradle_task "assembleRelease"
	run_android_gradle_task "packageDistribution"

	display_step "Running iOS build script with args: -cHPbz"
	run_ios_build "-cHPbz"

	display_step "Installing iOS plugin in demo app"
	$ROOT_DIR/ios/script/install.sh -t $DEMO_DIR -z $ROOT_DIR/ios/build/release/$PLUGIN_NAME-iOS-v$PLUGIN_VERSION.zip

	rm -rf $DEST_DIR
	display_step "Creating multi-platform release archive"
	create_multi_platform_archive

	display_step "Copying Android release archive"
	cp $ROOT_DIR/android/admob/build/dist/$PLUGIN_NAME-Android-v$PLUGIN_VERSION.zip $DEST_DIR

	display_step "Copying iOS release archive"
	cp $ROOT_DIR/ios/build/release/$PLUGIN_NAME-iOS-v$PLUGIN_VERSION.zip $DEST_DIR
fi
