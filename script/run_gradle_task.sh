#!/bin/bash
#
# © 2026-present https://github.com/cengiz-pz
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/..)
COMMON_DIR=$ROOT_DIR/common

gradle_build_task="build"

if ! [[ -z "${1:-}" ]]; then
	gradle_build_task=$1
fi


function display_help()
{
	echo
	$SCRIPT_DIR/echocolor.sh -y "The " -Y "$0 script" -y " runs the specified gradle build task."
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Syntax:"
	echo_yellow "	$0 [-h] <gradle-build-task-name>"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	echo_yellow "	h	display usage information"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Examples:"
	echo_yellow "	* generate plugin's GDScript code"
	echo_yellow "		$> $0 generateGDScript"
	echo
	echo_yellow "	* generate GDScript code and Android release AAR"
	echo_yellow "		$> $0 buildRelease"
	echo
	echo_yellow "	* generate GDScript code, Android debug & release AARs, and create Android "
	echo_yellow "	release archive"
	echo_yellow "		$> $0 createArchive"
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
	display_step "Running gradle task $gradle_build_task"

	pushd $COMMON_DIR
	$COMMON_DIR/gradlew $gradle_build_task
	popd
}


while getopts "h" option; do
	case $option in
		h)
			display_help
			exit;;
		\?)
			display_error "Error: invalid option"
			echo
			display_help
			exit;;
	esac
done


# Shift away the processed options
shift $((OPTIND - 1))


run_android_gradle_task
