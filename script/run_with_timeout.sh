#!/bin/bash
#
# © 2024-present https://github.com/cengiz-pz
#

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

function display_help()
{
	echo
	$SCRIPT_DIR/echocolor.sh -y "The " -Y "$0 script" -y " runs specified command for specified number of seconds,"
	$SCRIPT_DIR/echocolor.sh -y "then stops the command and exits."
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Syntax:"
	$SCRIPT_DIR/echocolor.sh -y "	$0 [-h] [-d <directory to run command in>] -t <timeout in seconds> -c <command to run>"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Options:"
	$SCRIPT_DIR/echocolor.sh -y "	h	display usage information"
	$SCRIPT_DIR/echocolor.sh -y "	t	timeout value in seconds"
	$SCRIPT_DIR/echocolor.sh -y "	c	command to run"
	$SCRIPT_DIR/echocolor.sh -y "	d	run command in specified directory"
	echo
	$SCRIPT_DIR/echocolor.sh -Y "Examples:"
	$SCRIPT_DIR/echocolor.sh -y "		$> $0 -t 10 -c 'my_command'"
	echo
}

function display_error()
{
	$SCRIPT_DIR/echocolor.sh -r "$1"
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

# Log file for debugging command errors
LOG_FILE="/tmp/run_with_timeout_$$.log"

# Run the command in a background subshell, suppressing shell notifications
{
	(
		if ! [[ -z $RUN_DIRECTORY ]]
		then
			if ! cd "$RUN_DIRECTORY"; then
				display_error "Error: Failed to change to directory $RUN_DIRECTORY" >> "$LOG_FILE"
				exit 1
			fi
			echo "Current directory: $(pwd)"
		fi

		# Export environment variables for command
		export PATH=$PATH:/usr/local/bin
		export SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path 2>>"$LOG_FILE" || echo "")

		# Verify command exists
		command -v "${RUN_COMMAND%% *}" >/dev/null 2>&1 || {
			display_error "Error: Command '${RUN_COMMAND%% *}' not found" >> "$LOG_FILE"
			exit 1
		}

		# Run the command, suppressing stdout and logging stderr
		bash -c "$RUN_COMMAND >/dev/null 2>>$LOG_FILE"
	) &
} 2>/dev/null

# Store the PID of the background subshell
pid=$!

# Debug: Print the PID
echo "Background process PID: $pid"

# Ensure directory message is printed before timer
sleep 0.1

# Display countdown timer on a new line
echo
for ((i=$RUN_TIMEOUT; i>=0; i--)); do
	printf "\rTime remaining: %02d seconds" $i
	sleep 1
done
echo -e "\nTerminating build after $RUN_TIMEOUT seconds..."

# Terminate child processes of the subshell
remaining_processes=$(pgrep -P $pid 2>/dev/null)
if [ -n "$remaining_processes" ]; then
	kill -TERM $remaining_processes 2>/dev/null || true
	sleep 1
	remaining_processes=$(pgrep -P $pid 2>/dev/null)
	if [ -n "$remaining_processes" ]; then
		echo "Processes still running, sending SIGKILL to child processes"
		kill -KILL $remaining_processes 2>/dev/null || true
		sleep 1
		remaining_processes=$(pgrep -P $pid 2>/dev/null)
	fi
fi

# Final check for any remaining processes
remaining_processes=$(pgrep -P $pid 2>/dev/null)
if [ -n "$remaining_processes" ]; then
	echo "Warning: Some processes may still be running."
	echo "Remaining processes:"
	ps -p "$remaining_processes" 2>/dev/null || echo "No processes found."
else
	echo "Build successfully terminated."
fi

# Show any logged errors
if [ -s "$LOG_FILE" ]; then
	# Filter out non-error messages
	if grep -E "error|Error|not found|failed" "$LOG_FILE" >/dev/null 2>&1; then
		echo "Command errors logged:"
		grep -E "error|Error|not found|failed" "$LOG_FILE"
	fi
fi

# Clean up log file
rm -f "$LOG_FILE"
