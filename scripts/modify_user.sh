#!/bin/bash

# modify_user.sh - Script to modify user properties
# This script is designed to work with the UserCTRL Pro GUI

# Set up logging
LOG_DIR="../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/user_management_$(date +%Y%m%d).log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_message "Starting modify_user.sh script"

# Default values
USERNAME=""
NEW_USERNAME=""
NEW_SHELL=""
NEW_HOME=""
MOVE_HOME=false
GROUPS=""
ADD_GROUPS=false
NEW_ROLE=""

# Parse command line arguments
while getopts "u:n:s:d:maG:r:" opt; do
    case $opt in
        u)
            USERNAME="$OPTARG"
            ;;
        n)
            NEW_USERNAME="$OPTARG"
            ;;
        s)
            NEW_SHELL="$OPTARG"
            ;;
        d)
            NEW_HOME="$OPTARG"
            ;;
        m)
            MOVE_HOME=true
            ;;
        a)
            ADD_GROUPS=true
            ;;
        G)
            GROUPS="$OPTARG"
            ;;
        r)
            NEW_ROLE="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Validate inputs
if [ -z "$USERNAME" ]; then
    echo "Error: Username is required"
    log_message "Error: Username is required"
    exit 1
fi

# Check if user exists
if ! id "$USERNAME" &>/dev/null; then
    echo "Error: User $USERNAME does not exist"
    log_message "Error: User $USERNAME does not exist"
    exit 1
fi

# Check if any modifications are specified
if [ -z "$NEW_USERNAME" ] && [ -z "$NEW_SHELL" ] && [ -z "$NEW_HOME" ] && [ -z "$GROUPS" ] && [ -z "$NEW_ROLE" ]; then
    echo "Error: No modifications specified"
    log_message "Error: No modifications specified for user $USERNAME"
    exit 1
fi

# Build usermod command
USERMOD_CMD="usermod"
CHANGES_MADE=false

# Add new username if specified
if [ -n "$NEW_USERNAME" ]; then
    USERMOD_CMD="$USERMOD_CMD -l $NEW_USERNAME"
    CHANGES_MADE=true
    log_message "Changing username from $USERNAME to $NEW_USERNAME"
fi

# Add new shell if specified
if [ -n "$NEW_SHELL" ]; then
    USERMOD_CMD="$USERMOD_CMD -s $NEW_SHELL"
    CHANGES_MADE=true
    log_message "Changing shell for user $USERNAME to $NEW_SHELL"
fi

# Add new home directory if specified
if [ -n "$NEW_HOME" ]; then
    if [ "$MOVE_HOME" = true ]; then
        USERMOD_CMD="$USERMOD_CMD -d $NEW_HOME -m"
        log_message "Moving home directory for user $USERNAME to $NEW_HOME"
    else
        USERMOD_CMD="$USERMOD_CMD -d $NEW_HOME"
        log_message "Setting home directory for user $USERNAME to $NEW_HOME (not moving contents)"
    fi
    CHANGES_MADE=true
fi

# Add groups if specified
if [ -n "$GROUPS" ]; then
    if [ "$ADD_GROUPS" = true ]; then
        USERMOD_CMD="$USERMOD_CMD -a -G $GROUPS"
        log_message "Adding user $USERNAME to groups: $GROUPS"
    else
        USERMOD_CMD="$USERMOD_CMD -G $GROUPS"
        log_message "Setting groups for user $USERNAME to: $GROUPS"
    fi
    CHANGES_MADE=true
fi

# Execute the usermod command if changes were made
if [ "$CHANGES_MADE" = true ]; then
    $USERMOD_CMD "$USERNAME"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to modify user $USERNAME"
        log_message "Error: Failed to modify user $USERNAME"
        exit 1
    fi
fi

# Handle role change if specified
if [ -n "$NEW_ROLE" ]; then
    # Remove user from existing role groups
    for role_group in admin sudo student guest; do
        gpasswd -d "$USERNAME" "$role_group" 2>/dev/null
    done
    
    # Add user to new role group
    case "$NEW_ROLE" in
        "admin")
            # Create admin group if it doesn't exist
            if ! getent group admin > /dev/null; then
                groupadd admin
            fi
            usermod -aG sudo,admin "$USERNAME"
            log_message "Changed role for user $USERNAME to admin"
            ;;
        "student")
            # Create student group if it doesn't exist
            if ! getent group student > /dev/null; then
                groupadd student
            fi
            usermod -aG student "$USERNAME"
            log_message "Changed role for user $USERNAME to student"
            ;;
        "guest")
            # Create guest group if it doesn't exist
            if ! getent group guest > /dev/null; then
                groupadd guest
            fi
            usermod -aG guest "$USERNAME"
            log_message "Changed role for user $USERNAME to guest"
            ;;
        *)
            echo "Error: Invalid role $NEW_ROLE"
            log_message "Error: Invalid role $NEW_ROLE for user $USERNAME"
            ;;
    esac
    
    CHANGES_MADE=true
fi

# If username was changed, update the log to reflect the new username
if [ -n "$NEW_USERNAME" ]; then
    log_message "User $USERNAME successfully modified (now $NEW_USERNAME)"
    echo "User $USERNAME successfully modified (now $NEW_USERNAME)"
else
    log_message "User $USERNAME successfully modified"
    echo "User $USERNAME successfully modified"
fi

exit 0
