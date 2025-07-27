#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function display_help()
{
	echo
	$SCRIPT_DIR/../../script/echocolor.sh -y "The " -Y "$0 script" -y " runs specified command for specified number of seconds,"
	$SCRIPT_DIR/../../script/echocolor.sh -y "then stops the command and exits."
	echo
	$SCRIPT_DIR/../../script/echocolor.sh -Y "Syntax:"
	$SCRIPT_DIR/../../script/echocolor.sh -y "	$0 [-h] [-d <directory to run command in>] -t <timeout in seconds> -c <command to run>"
	echo
	$SCRIPT_DIR/../../script/echocolor.sh -Y "Options:"
	$SCRIPT_DIR/../../script/echocolor.sh -y "	h	display usage information"
	$SCRIPT_DIR/../../script/echocolor.sh -y "	t	timeout value in seconds"
	$SCRIPT_DIR/../../script/echocolor.sh -y "	c	command to run"
	$SCRIPT_DIR/../../script/echocolor.sh -y "	d	run command in specified directory"
	echo
	$SCRIPT_DIR/../../script/echocolor.sh -Y "Examples:"
	$SCRIPT_DIR/../../script/echocolor.sh -y "		$> $0 -t 10 -c 'my_command'"
	echo
}


function display_error()
{
	$SCRIPT_DIR/../../script/echocolor.sh -r "$1"
}


min_expected_arguments=1

if [[ $# -lt $min_expected_arguments ]]
then
	display_error "Error: Expected at least $min_expected_arguments arguments, found $#."
	echo
	display_help
	exit 1
fi

RUN_TIMEOUT=''
RUN_COMMAND=''
RUN_DIRECTORY=''

while getopts "hd:t:c:" option
do
	case $option in
		c)
			RUN_COMMAND=$OPTARG
			;;
		d)
			RUN_DIRECTORY=$OPTARG
			;;
		h)
			display_help
			exit;;
		t)
			RUN_TIMEOUT=$OPTARG
			;;
		\?)
			display_error "Error: invalid option"
			echo
			display_help
			exit;;
	esac
done

regex='^[0-9]+$'
if ! [[ $RUN_TIMEOUT =~ $regex ]]
then
	display_error "Error: The value for timeout option should be an integer. Found $RUN_TIMEOUT."
	echo
	display_help
	exit 1
fi

(
	if ! [[ -z $RUN_DIRECTORY ]]
	then
		cd $RUN_DIRECTORY
		echo "current directory is $(pwd)"
	fi

	eval $RUN_COMMAND
) 2> /dev/null &

sleep $RUN_TIMEOUT

pkill -P $! || true

sleep 1
