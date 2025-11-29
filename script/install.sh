#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -e
trap "sleep 1; echo" EXIT

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

target_directory=""
zip_file_path=""


function display_help()
{
	echo
	$SCRIPT_DIR/echocolor.sh -y "The " -Y "$0 script" -y " installs plugin in the specified directory"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Syntax:"
	$SCRIPT_DIR/echocolor.sh -y "	$0 [-h|t <target directory path>|z <zip file path>]"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	$SCRIPT_DIR/echocolor.sh -y "	h	display usage information"
	$SCRIPT_DIR/echocolor.sh -y "	t	specify the path for target directory"
	$SCRIPT_DIR/echocolor.sh -y "	z	specify the path for zip file"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Examples:"
	$SCRIPT_DIR/echocolor.sh -y "	* install plugin in project"
	$SCRIPT_DIR/echocolor.sh -y "		$> $0 -t /mypath/myproject -z ../myzipfile.zip"
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


function display_warning()
{
	$SCRIPT_DIR/echocolor.sh -y "$1"
}


function display_error()
{
	$SCRIPT_DIR/echocolor.sh -r "$1"
}


while getopts "hdt:z:" option; do
	case $option in
		h)
			display_help
			exit;;
		t)
			if ! [[ -z $OPTARG ]]
			then
				target_directory=$OPTARG
			fi
			;;
		z)
			if ! [[ -z $OPTARG ]]
			then
				zip_file_path=$OPTARG
			fi
			;;
		\?)
			display_error "Error: invalid option"
			echo
			display_help
			exit;;
	esac
done

if [[ ! -f "$zip_file_path" ]]
then
	display_error "Error: zip file '$zip_file_path' not found"
	exit 1
fi

if [[ ! -d "$target_directory" ]]
then
	display_status "Creating target directory $target_directory"
	mkdir -p $target_directory
fi

display_status "Installing $zip_file_path in $target_directory"

unzip -o $zip_file_path -d $target_directory
