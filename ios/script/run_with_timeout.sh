#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(realpath $SCRIPT_DIR/../..)

function display_help()
{
	echo
	$ROOT_DIR/script/echocolor.sh -y "The " -Y "$0 script" -y " runs specified command for specified number of seconds,"
	$ROOT_DIR/script/echocolor.sh -y "then stops the command and exits."
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Syntax:"
	$ROOT_DIR/script/echocolor.sh -y "	$0 [-h] [-d <directory to run command in>] -t <timeout in seconds> -c <command to run>"
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Options:"
	$ROOT_DIR/script/echocolor.sh -y "	h	display usage information"
	$ROOT_DIR/script/echocolor.sh -y "	t	timeout value in seconds"
	$ROOT_DIR/script/echocolor.sh -y "	c	command to run"
	$ROOT_DIR/script/echocolor.sh -y "	d	run command in specified directory"
	echo
	$ROOT_DIR/script/echocolor.sh -Y "Examples:"
	$ROOT_DIR/script/echocolor.sh -y "		$> $0 -t 10 -c 'my_command'"
	echo
}

function display_error()
{
	$ROOT_DIR/script/echocolor.sh -r "$1"
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

# Debug: Print the command and directory
echo "Executing command: $RUN_COMMAND"
if ! [[ -z $RUN_DIRECTORY ]]; then
	echo "Target directory: $RUN_DIRECTORY"
fi

# Run the command in a new session/process group using setsid
(
	if ! [[ -z $RUN_DIRECTORY ]]
	then
		if ! cd "$RUN_DIRECTORY"; then
			echo "Error: Failed to change to directory $RUN_DIRECTORY"
			exit 1
		fi
		echo "Current directory: $(pwd)"
	fi

	# Run the command with setsid, suppressing all output
	setsid bash -c "$RUN_COMMAND >/dev/null 2>&1"
) 2> /dev/null &

# Store the PID of the background subshell
pid=$!

# Debug: Print the PID
echo "Background process PID: $pid"

# Ensure directory message is printed before timer
sleep 0.1

# Display countdown timer on a new line
echo
for ((i=$RUN_TIMEOUT; i>=0; i--)); do
	printf "\rTime remaining: %2d seconds" $i
	sleep 1
done
echo -e "\nTerminating build after $RUN_TIMEOUT seconds..."

# Get the process group ID of the subshell
pgid=$(ps -p $pid -o pgid= 2>/dev/null | tr -d ' ')

# Send SIGTERM to the process group
if [ -n "$pgid" ] && ps -p $pid >/dev/null 2>&1; then
	kill -TERM -- -"$pgid" 2>/dev/null || true
fi

# Wait briefly for clean termination
sleep 1

# Check for remaining processes in the process group
remaining_processes=$(pgrep -g "$pgid" 2>/dev/null)
if [ -n "$pgid" ] && [ -n "$remaining_processes" ]; then
	echo "Processes still running, sending SIGKILL to process group"
	kill -KILL -- -"$pgid" 2>/dev/null || true
	sleep 1
	# Recheck for remaining processes
	remaining_processes=$(pgrep -g "$pgid" 2>/dev/null)
fi

# Final check for any remaining processes
if [ -n "$pgid" ] && [ -n "$remaining_processes" ]; then
	echo "Warning: Some processes may still be running."
	echo "Remaining processes in group $pgid:"
	ps -g "$pgid" 2>/dev/null || echo "No processes found."
else
	echo "Build successfully terminated."
fi
