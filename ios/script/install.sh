#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

set -e
trap "sleep 1; echo" EXIT

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/../..)

target_directory=""
zip_file_path=""


function display_help()
{
	echo
	$ROOT_DIR/script/echocolor.sh -y "The " -Y "$0 script" -y " installs plugin in the specified directory"
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Syntax:"
	$ROOT_DIR/script/echocolor.sh -y "	$0 [-h|d|t <target directory path>|z <zip file path>]"
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Options:"
	$ROOT_DIR/script/echocolor.sh -y "	h	display usage information"
	$ROOT_DIR/script/echocolor.sh -y "	t	specify the path for target directory"
	$ROOT_DIR/script/echocolor.sh -y "	z	specify the path for zip file"
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Examples:"
	$ROOT_DIR/script/echocolor.sh -y "	* install plugin in project"
	$ROOT_DIR/script/echocolor.sh -y "		$> $0 -t /mypath/myproject -z ../myzipfile.zip"
	echo
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
	$ROOT_DIR/script/echocolor.sh -y "$1"
}


function display_error()
{
	$ROOT_DIR/script/echocolor.sh -r "$1"
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
	display_status "creating target directory $target_directory"
	mkdir -p $target_directory
fi

display_status "installing $zip_file_path in $target_directory"

unzip -o $zip_file_path -d $target_directory
