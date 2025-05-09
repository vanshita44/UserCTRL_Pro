#!/bin/bash

# add_user.sh - Script to add a new user to the system
# This script is designed to work with the UserCTRL Pro GUI

# Set up logging
LOG_DIR="../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/user_management_$(date +%Y%m%d).log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_message "Starting add_user.sh script"

# Read input from stdin
read -r username
read -r role
read -r password
read -r confirm_password

# Validate inputs
if [ -z "$username" ]; then
    echo "Error: Username is required"
    log_message "Error: Username is required"
    exit 1
fi

if [ -z "$password" ]; then
    echo "Error: Password is required"
    log_message "Error: Password is required"
    exit 1
fi

if [ "$password" != "$confirm_password" ]; then
    echo "Error: Passwords do not match"
    log_message "Error: Passwords do not match for user $username"
    exit 1
fi

# Check if user already exists
if id "$username" &>/dev/null; then
    echo "Error: User $username already exists"
    log_message "Error: User $username already exists"
    exit 1
fi

# Add the user
useradd -m -s /bin/bash "$username"
if [ $? -ne 0 ]; then
    echo "Error: Failed to create user $username"
    log_message "Error: Failed to create user $username"
    exit 1
fi

# Set password
echo "$username:$password" | chpasswd
if [ $? -ne 0 ]; then
    echo "Error: Failed to set password for user $username"
    log_message "Error: Failed to set password for user $username"
    exit 1
fi

# Add user to appropriate group based on role
case "$role" in
    "admin")
        usermod -aG sudo "$username"
        ;;
    "student")
        # Create student group if it doesn't exist
        if ! getent group student > /dev/null; then
            groupadd student
        fi
        usermod -aG student "$username"
        ;;
    "guest")
        # Create guest group if it doesn't exist
        if ! getent group guest > /dev/null; then
            groupadd guest
        fi
        usermod -aG guest "$username"
        ;;
    *)
        # Default to regular user with no special group
        ;;
esac

# Set up user's home directory with appropriate permissions
chmod 750 "/home/$username"

# Log the successful user creation
log_message "User $username successfully created with role $role"
echo "User $username successfully created with role $role"

exit 0
