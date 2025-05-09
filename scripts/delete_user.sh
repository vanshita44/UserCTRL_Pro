#!/bin/bash

# delete_user.sh - Script to delete a user from the system
# This script is designed to work with the UserCTRL Pro GUI

# Set up logging
LOG_DIR="../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/user_management_$(date +%Y%m%d).log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_message "Starting delete_user.sh script"

# Read input from stdin
read -r username
read -r confirm
read -r keep_home

# Validate inputs
if [ -z "$username" ]; then
    echo "Error: Username is required"
    log_message "Error: Username is required"
    exit 1
fi

if [ "$confirm" != "y" ]; then
    echo "Operation cancelled by user"
    log_message "User deletion cancelled for $username"
    exit 0
fi

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "Error: User $username does not exist"
    log_message "Error: User $username does not exist"
    exit 1
fi

# Delete the user
if [ "$keep_home" = "y" ]; then
    userdel "$username"
    log_message "Deleted user $username (keeping home directory)"
    echo "User $username successfully deleted (home directory preserved)"
else
    userdel -r "$username"
    log_message "Deleted user $username (including home directory)"
    echo "User $username successfully deleted (including home directory)"
fi

if [ $? -ne 0 ]; then
    echo "Error: Failed to delete user $username"
    log_message "Error: Failed to delete user $username"
    exit 1
fi

exit 0
