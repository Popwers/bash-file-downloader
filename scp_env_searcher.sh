#!/bin/bash

# Define text colors and emojis
GREEN="\033[0;32m"
RED="\033[0;91m"
BLUE="\033[0;34m"
ORANGE="\033[0;33m"
RESET="\033[0m"

CHECK_MARK="✅"
WARNING="⚠️"
INFO="ℹ️"
ERROR="❌"

# Initialize variables with default values
SSH_KEY=""
REMOTE_USER=""
REMOTE_SERVER=""
LOCAL_DIRECTORY=""
FILE_PATTERN=""

# Function to display progress messages
show_progress() {
  local message_type="$1"
  local message="$2"
  local color
  local emoji
  local newline="$3"
  local spaces

  case "$message_type" in
    "success")
      color="$GREEN"
      emoji="$CHECK_MARK"
      spaces=" "
      ;;
    "warning")
      color="$ORANGE"
      emoji="$WARNING"
      spaces="  "
      ;;
    "info")
      color="$BLUE"
      emoji="$INFO"
      spaces="  "
      ;;
    "error")
      color="$RED"
      emoji="$ERROR"
      spaces=" "
      ;;
    *)
      color="$RESET"
      emoji=""
      spaces="  "
      ;;
  esac

  # Print message with appropriate color and emoji
  echo -e "${emoji}${spaces}${color}${message}${RESET}${newline}"
}

# Function to display usage instructions
usage() {
  echo "Usage: $0 -i <SSH_KEY> -u <REMOTE_USER> -s <REMOTE_SERVER> -d <LOCAL_DIRECTORY> -f <FILE_PATTERN>"
  echo "Options:"
  echo "  -i  SSH_KEY        : SSH private key file (e.g., ./path/to/key.pem)"
  echo "  -u  REMOTE_USER    : Remote user (e.g., admin)"
  echo "  -s  REMOTE_SERVER  : Remote server address (e.g., ec2-xxx-xxx-xxx-xxx.compute.amazonaws.com)"
  echo "  -d  LOCAL_DIRECTORY: Local directory where files will be copied"
  echo "  -f  FILE_PATTERN   : File pattern to search for (e.g., '.env*')"
  exit 1
}

# Function to create the LOCAL_DIRECTORY if it doesn't exist
create_local_directory() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

# Function to check if rsync is available on the remote server
is_rsync_available() {
  ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_SERVER" "command -v rsync > /dev/null 2>&1 && echo 'true' || echo 'false'"
}

# Parse command line arguments
while getopts "i:u:s:d:f:" opt; do
  case $opt in
    i)
      SSH_KEY="$OPTARG"
      ;;
    u)
      REMOTE_USER="$OPTARG"
      ;;
    s)
      REMOTE_SERVER="$OPTARG"
      ;;
    d)
      LOCAL_DIRECTORY="$OPTARG"
      ;;
    f)
      FILE_PATTERN="$OPTARG"
      ;;
    *)
      usage
      ;;
  esac
done

# Check if required parameters are provided
if [ -z "$SSH_KEY" ] || [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_SERVER" ] || [ -z "$LOCAL_DIRECTORY" ] || [ -z "$FILE_PATTERN" ]; then
  usage
fi

show_progress "info" "Searching for $FILE_PATTERN files on $REMOTE_SERVER..."

# Check if rsync is available on the remote server
RSYNC_AVAILABLE=$(is_rsync_available)

# Execute the remote find command and capture the results
REMOTE_COMMAND="sudo find ~/ -type f -name '$FILE_PATTERN' -exec echo {} \;"
SSH_OUTPUT=$(ssh -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_SERVER" "$REMOTE_COMMAND")

# Check if any files were found
if [ -z "$SSH_OUTPUT" ]; then
  show_progress "info" "No $FILE_PATTERN files were found on $REMOTE_SERVER."
else
  # Check if the LOCAL_DIRECTORY exists or create it
  create_local_directory "$LOCAL_DIRECTORY"

  # Display the found files
  show_progress "success" "Found $FILE_PATTERN files on $REMOTE_SERVER :\n\n$SSH_OUTPUT"
  show_progress "" "" "\n"

  # Copy files using rsync if available, otherwise use scp
  if [ "$RSYNC_AVAILABLE" == "true" ]; then
    show_progress "info" "Copying files using rsync..."
    show_progress "" "" "\n"
    rsync -avz -e "ssh -i $SSH_KEY" --progress --relative --files-from=<(echo "$SSH_OUTPUT") "$REMOTE_USER@$REMOTE_SERVER:" "$LOCAL_DIRECTORY"
  else
    show_progress "info" "Copying files using scp..."
    show_progress "" "" "\n"
    while IFS= read -r file; do
      destination="$LOCAL_DIRECTORY/${file#*/}"
      mkdir -p "$(dirname "$destination")"
      show_progress "info" "Copying $file to $destination..."
      scp -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_SERVER:$file" "$destination"
    done <<< "$SSH_OUTPUT"
  fi

  show_progress "" "" "\n"
  show_progress "success" "Copy completed. Files are copied to $LOCAL_DIRECTORY."
fi
