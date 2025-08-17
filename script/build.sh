#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -e
trap "sleep 1; echo" EXIT

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/..)

do_clean=false
do_build_android=false
gradle_build_task="assembleDebug"
do_create_archive=false


function display_help()
{
	echo
	$SCRIPT_DIR/echocolor.sh -y "The " -Y "$0 script" -y " builds the plugin and creates a zip file containing all"
	$SCRIPT_DIR/echocolor.sh -y "libraries and configuration."
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Syntax:"
	$SCRIPT_DIR/echocolor.sh -y "	$0 [-a|c|h|i|r|z]"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	$SCRIPT_DIR/echocolor.sh -y "	a	build plugin for the Android platform"
	$SCRIPT_DIR/echocolor.sh -y "	c	remove any existing plugin build"
	$SCRIPT_DIR/echocolor.sh -y "	h	display usage information"
	$SCRIPT_DIR/echocolor.sh -y "	r	build release variant"
	$SCRIPT_DIR/echocolor.sh -y "	z	create zip archive"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Examples:"
	$SCRIPT_DIR/echocolor.sh -y "	* clean existing build, do a release build for Android, and create archive"
	$SCRIPT_DIR/echocolor.sh -y "		$> $0 -carz"
	echo
	$SCRIPT_DIR/echocolor.sh -y "	* clean existing build, do a debug build for Android"
	$SCRIPT_DIR/echocolor.sh -y "		$> $0 -ca"
	echo
}


function display_status()
{
	echo
	$SCRIPT_DIR/echocolor.sh -c "********************************************************************************"
	$SCRIPT_DIR/echocolor.sh -c "* $1"
	$SCRIPT_DIR/echocolor.sh -c "********************************************************************************"
	echo
}


function display_error()
{
	$SCRIPT_DIR/echocolor.sh -r "$1"
}


while getopts "achrz" option; do
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
		r)
			gradle_build_task="assembleRelease"
			;;
		z)
			if ! [[ -z $OPTARG ]]
			then
				PLUGIN_VERSION=$OPTARG
			fi
			do_create_archive=true
			;;
		\?)
			display_error "Error: invalid option"
			echo
			display_help
			exit;;
	esac
done

if [[ "$do_clean" == true ]]
then
	display_status "Cleaning build"
	pushd android
	$ROOT_DIR/android/gradlew clean
	popd
fi

if [[ "$do_build_android" == true ]]
then
	display_status "Building android"
	pushd android
	$ROOT_DIR/android/gradlew $gradle_build_task
	popd
fi

if [[ "$do_create_archive" == true ]]
then
	display_status "Creating archive"
	pushd android
	$ROOT_DIR/android/gradlew packageDistribution
	popd
fi
