#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

do_clean=false
do_reset_spm=false
do_remove_godot=false
do_download_godot=false
do_update_spm=false
do_resolve_spm_dependencies=false
do_debug_build=false
do_release_build=false
do_simulator_build=false
do_create_archive=false
do_uninstall=false
do_install=false
do_run_tests=false


function display_help()
{
	echo
	"$SCRIPT_DIR"/echocolor.sh -y "The " -Y "$0 script" -y " builds the plugin, generates library archives, and"
	echo_yellow "creates a zip file containing all libraries and configuration."
	echo
	echo_yellow "If plugin version is not set with the -z option, then Godot version will be used."
	echo
	"$SCRIPT_DIR"/echocolor.sh -Y "Syntax:"
	echo_yellow "	$0 [-a|A|b|B|c|d|D|g|G|h|p|P|r|R|s|t]"
	echo
	"$SCRIPT_DIR"/echocolor.sh -Y "Options:"
	echo_yellow "	a	update SPM and build both variants of plugin"
	echo_yellow "	A	download godot headers for the configured version, update SPM, and build both variants of"
	echo_yellow "	 	build plugin"
	echo_yellow "	b	build debug variant of plugin (device); combine with -s for simulator"
	echo_yellow "	B	build release variant of plugin (device); combine with -s for simulator"
	echo_yellow "	c	remove any existing plugin build"
	echo_yellow "	d	uninstall iOS plugin from demo app"
	echo_yellow "	D	install iOS plugin to demo app"
	echo_yellow "	g	remove directory with godot header files"
	echo_yellow "	G	download the configured godot headers version into godot directory"
	echo_yellow "	h	display usage information"
	echo_yellow "	p	remove SPM packages and build artifacts"
	echo_yellow "	P	add SPM packages from configuration"
	echo_yellow "	r	resolve SPM dependencies"
	echo_yellow "	R	create iOS release archive"
	echo_yellow "	s	simulator build; use with -b for simulator debug, -B for simulator release"
	echo_yellow "	t	run iOS tests (shows per-suite pass/fail table and code coverage)"
	echo
	"$SCRIPT_DIR"/echocolor.sh -Y "Examples:"
	echo_yellow "	* clean existing build, remove godot, and rebuild all"
	echo_yellow "		$> $0 -cgA"
	echo_yellow "		$> $0 -cgpGPb"
	echo
	echo_yellow "	* clean existing build, remove SPM packages, and rerun debug build"
	echo_yellow "		$> $0 -cpPb"
	echo
	echo_yellow "	* clean existing build and rebuild plugin"
	echo_yellow "		$> $0 -ca"
	echo
	echo_yellow "	* clean existing build and rebuild plugin and create release archive"
	echo_yellow "		$> $0 -R"
	echo
}


function echo_yellow()
{
	"$SCRIPT_DIR"/echocolor.sh -y "$1"
}


function echo_blue()
{
	"$SCRIPT_DIR"/echocolor.sh -B "$1"
}


function echo_green()
{
	"$SCRIPT_DIR"/echocolor.sh -g "$1"
}


function display_status()
{
	echo
	"$SCRIPT_DIR"/echocolor.sh -c "********************************************************************************"
	"$SCRIPT_DIR"/echocolor.sh -c "* $1"
	"$SCRIPT_DIR"/echocolor.sh -c "********************************************************************************"
	echo
}


function display_progress()
{
	echo_green "$1"
	echo
}


function display_warning()
{
	echo_yellow "Warning: $1"
	echo
}


function display_error()
{
	"$SCRIPT_DIR"/echocolor.sh -r "Error: $1"
}


while getopts "aAbBcdDgGhpPrRst" option; do
	case $option in
		h)
			display_help
			exit;;
		a)
			do_update_spm=true
			do_debug_build=true
			do_release_build=true
			;;
		A)
			do_download_godot=true
			do_update_spm=true
			do_debug_build=true
			do_release_build=true
			;;
		b)
			do_debug_build=true
			;;
		B)
			do_release_build=true
			;;
		c)
			do_clean=true
			;;
		d)
			do_uninstall=true
			;;
		D)
			do_install=true
			;;
		g)
			do_remove_godot=true
			;;
		G)
			do_download_godot=true
			;;
		p)
			do_reset_spm=true
			;;
		P)
			do_update_spm=true
			;;
		r)
			do_resolve_spm_dependencies=true
			;;
		R)
			do_create_archive=true
			;;
		s)
			do_simulator_build=true
			;;
		t)
			do_run_tests=true
			;;
		\?)
			display_error "invalid option"
			echo
			display_help
			exit;;
	esac
done


if [[ "$do_uninstall" == true ]]
then
	display_status "Uninstalling iOS plugin from demo app"
	"$SCRIPT_DIR"/run_gradle_task.sh "uninstalliOS"
fi

if [[ "$do_clean" == true ]]
then
	"$SCRIPT_DIR"/run_gradle_task.sh "cleaniOS"
fi

if [[ "$do_reset_spm" == true ]]
then
	"$SCRIPT_DIR"/run_gradle_task.sh "resetSPMDependencies"
fi

if [[ "$do_remove_godot" == true ]]
then
	"$SCRIPT_DIR"/run_gradle_task.sh "removeGodotDirectory"
fi

if [[ "$do_download_godot" == true ]]
then
	"$SCRIPT_DIR"/run_gradle_task.sh "downloadGodotHeaders"
fi

if [[ "$do_update_spm" == true ]]
then
	"$SCRIPT_DIR"/run_gradle_task.sh "updateSPMDependencies"
fi

if [[ "$do_resolve_spm_dependencies" == true ]]
then
	"$SCRIPT_DIR"/run_gradle_task.sh "resolveSPMDependencies"
fi

if [[ "$do_debug_build" == true ]]
then
	if [[ "$do_simulator_build" == true ]]; then
		"$SCRIPT_DIR"/run_gradle_task.sh "buildiOSDebugSimulator"
	else
		"$SCRIPT_DIR"/run_gradle_task.sh "buildiOSDebug"
	fi
fi

if [[ "$do_release_build" == true ]]
then
	if [[ "$do_simulator_build" == true ]]; then
		"$SCRIPT_DIR"/run_gradle_task.sh "buildiOSReleaseSimulator"
	else
		"$SCRIPT_DIR"/run_gradle_task.sh "buildiOSRelease"
	fi
fi

if [[ "$do_create_archive" == true ]]
then
	display_status "Creating iOS archive"
	"$SCRIPT_DIR"/run_gradle_task.sh "createiOSArchive"
fi

if [[ "$do_install" == true ]]
then
	display_status "Installing iOS plugin to demo app"
	"$SCRIPT_DIR"/run_gradle_task.sh "installToDemoiOS"
fi

if [[ "$do_run_tests" == true ]]
then
	display_status "Running iOS tests"
	"$SCRIPT_DIR"/run_gradle_task.sh ":ios:testiOS"
fi
