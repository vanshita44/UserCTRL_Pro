#!/bin/bash

# lock_user.sh - Script to lock or unlock a user account
# This script is designed to work with the UserCTRL Pro GUI

# Set up logging
LOG_DIR="../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/user_management_$(date +%Y%m%d).log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_message "Starting lock_user.sh script"

# Default values
UNLOCK=false
REASON=""
EXPIRE_DAYS=0

# Parse command line arguments
while getopts "ur:e:" opt; do
    case $opt in
        u)
            UNLOCK=true
            ;;
        r)
            REASON="$OPTARG"
            ;;
        e)
            EXPIRE_DAYS="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Read username from stdin
read -r username
read -r reason_input

# Use reason from command line or stdin
if [ -z "$REASON" ] && [ -n "$reason_input" ]; then
    REASON="$reason_input"
fi

# Validate inputs
if [ -z "$username" ]; then
    echo "Error: Username is required"
    log_message "Error: Username is required"
    exit 1
fi

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "Error: User $username does not exist"
    log_message "Error: User $username does not exist"
    exit 1
fi

# Lock or unlock the user account
if [ "$UNLOCK" = true ]; then
    # Unlock user
    usermod -U "$username"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to unlock user $username"
        log_message "Error: Failed to unlock user $username"
        exit 1
    fi
    
    # Remove expiry if any
    usermod --expiredate "" "$username"
    
    log_message "User $username unlocked successfully"
    echo "User $username unlocked successfully"
else
    # Lock user
    usermod -L "$username"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to lock user $username"
        log_message "Error: Failed to lock user $username"
        exit 1
    fi
    
    # Set account expiry if specified
    if [ "$EXPIRE_DAYS" -gt 0 ]; then
        # Calculate expiry date
        EXPIRE_DATE=$(date -d "+$EXPIRE_DAYS days" +%Y-%m-%d)
        usermod --expiredate "$EXPIRE_DATE" "$username"
        
        log_message "User $username locked until $EXPIRE_DATE. Reason: $REASON"
        echo "User $username locked successfully until $EXPIRE_DATE"
    else
        log_message "User $username locked. Reason: $REASON"
        echo "User $username locked successfully"
    fi
fi

exit 0
