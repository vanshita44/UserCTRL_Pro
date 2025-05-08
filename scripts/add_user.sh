#!/bin/bash

# Define log file
LOG_FILE="../logs/user_log.txt"

# Ensure log directory exists
mkdir -p $(dirname "$LOG_FILE")

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to validate username format
validate_username() {
    local username="$1"
    # Check if username contains only alphanumeric chars and underscore
    if ! [[ "$username" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Error: Username must contain only letters, numbers, and underscores."
        log_message "ERROR: Invalid username format: $username"
        return 1
    fi
    
    # Check username length (3-32 chars is standard)
    if [ ${#username} -lt 3 ] || [ ${#username} -gt 32 ]; then
        echo "Error: Username must be between 3 and 32 characters."
        log_message "ERROR: Invalid username length: $username"
        return 1
    fi
    
    return 0
}

# Function to check if group exists and create if needed
check_create_group() {
    local group="$1"
    if ! getent group "$group" > /dev/null; then
        echo "Group $group does not exist. Creating..."
        sudo groupadd "$group"
        if [ $? -eq 0 ]; then
            echo "Group $group created successfully."
            log_message "INFO: Created group: $group"
            return 0
        else
            echo "Failed to create group $group."
            log_message "ERROR: Failed to create group: $group"
            return 1
        fi
    fi
    return 0
}

# Ask for username and role
read -p "Enter username to add: " username

# Validate username format
if ! validate_username "$username"; then
    exit 1
fi

# Check if user already exists
if id "$username" &>/dev/null; then
    echo "User already exists!"
    log_message "ERROR: Attempted to create existing user: $username"
    exit 1
fi

read -p "Enter role (admin/student/guest): " role

# Check if empty
if [ -z "$username" ] || [ -z "$role" ]; then
    echo "Username and role are required!"
    log_message "ERROR: Empty username or role for user creation"
    exit 1
fi

# Password creation
read -s -p "Enter password for $username: " password
echo
read -s -p "Confirm password: " password_confirm
echo

if [ "$password" != "$password_confirm" ]; then
    echo "Passwords do not match!"
    log_message "ERROR: Password mismatch during user creation: $username"
    exit 1
fi

# Check password strength
if [ ${#password} -lt 8 ]; then
    echo "Password must be at least 8 characters long!"
    log_message "ERROR: Weak password during user creation: $username"
    exit 1
fi

# Create the user
sudo useradd -m "$username"
if [ $? -ne 0 ]; then
    echo "Failed to create user $username!"
    log_message "ERROR: Failed to create user: $username"
    exit 1
fi

# Set password
echo "$username:$password" | sudo chpasswd
if [ $? -ne 0 ]; then
    echo "Failed to set password for user $username!"
    log_message "ERROR: Failed to set password for user: $username"
    exit 1
fi

# Role-based settings
case $role in
    admin)
        # Check if sudo group exists
        check_create_group "sudo" || exit 1
        sudo usermod -aG sudo "$username"
        ;;
    student)
        # Check if students group exists
        check_create_group "students" || exit 1
        sudo usermod -aG students "$username"
        ;;
    guest)
        # Check if guests group exists
        check_create_group "guests" || exit 1
        sudo usermod -aG guests "$username"
        ;;
    *)
        echo "Unknown role. No special groups assigned."
        log_message "WARNING: Unknown role assigned to user: $username, role: $role"
        ;;
esac

echo "User $username added successfully with role $role."
log_message "SUCCESS: User created: $username with role: $role"
