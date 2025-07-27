#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -e
trap "sleep 1; echo" EXIT

DEST_DIRECTORY="./bin/release"
FRAMEWORKDIR="./bin/framework"
LIB_DIRECTORY="./bin/lib"
CONFIG_DIRECTORY="./config"

do_clean=false
do_build_android=false
gradle_build_task="assembleDebug"
do_create_archive=false


function display_help()
{
	echo
	./script/echocolor.sh -y "The " -Y "$0 script" -y " builds the plugin and creates a zip file containing all"
	./script/echocolor.sh -y "libraries and configuration."
	echo
	./script/echocolor.sh -Y "Syntax:"
	./script/echocolor.sh -y "	$0 [-a|c|h|i|r|z]"
	echo
	./script/echocolor.sh -Y "Options:"
	./script/echocolor.sh -y "	a	build plugin for the Android platform"
	./script/echocolor.sh -y "	c	remove any existing plugin build"
	./script/echocolor.sh -y "	h	display usage information"
	./script/echocolor.sh -y "	r	build release variant"
	./script/echocolor.sh -y "	z	create zip archive"
	echo
	./script/echocolor.sh -Y "Examples:"
	./script/echocolor.sh -y "	* clean existing build, do a release build for Android, and create archive"
	./script/echocolor.sh -y "		$> $0 -carz"
	echo
	./script/echocolor.sh -y "	* clean existing build, do a debug build for Android"
	./script/echocolor.sh -y "		$> $0 -ca"
	echo
}


function display_status()
{
	echo
	./script/echocolor.sh -c "********************************************************************************"
	./script/echocolor.sh -c "* $1"
	./script/echocolor.sh -c "********************************************************************************"
	echo
}


function display_error()
{
	./script/echocolor.sh -r "$1"
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
	./gradlew clean
	popd
fi

if [[ "$do_build_android" == true ]]
then
	display_status "Building android"
	pushd android
	./gradlew $gradle_build_task
	popd
fi

if [[ "$do_create_archive" == true ]]
then
	display_status "Creating archive"
	pushd android
	./gradlew packageDistribution
	popd
fi
