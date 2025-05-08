#!/bin/bash

# Define log file
LOG_FILE="../logs/user_log.txt"

# Ensure log directory exists
mkdir -p $(dirname "$LOG_FILE")

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to backup home directory
backup_home_dir() {
    local username="$1"
    local backup_dir="../backups/users"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$backup_dir"
    
    # Get user's home directory
    local home_dir=$(eval echo ~$username)
    
    if [ -d "$home_dir" ]; then
        local backup_file="$backup_dir/${username}-home-$(date +%Y%m%d-%H%M%S).tar.gz"
        tar -czf "$backup_file" "$home_dir" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "Home directory backed up to $backup_file"
            log_message "INFO: Home directory for $username backed up to $backup_file"
            return 0
        else
            echo "Failed to backup home directory for $username"
            log_message "ERROR: Failed to backup home directory for $username"
            return 1
        fi
    else
        echo "Home directory for $username not found or not accessible"
        log_message "WARNING: Home directory for $username not found during backup attempt"
        return 1
    fi
}

# Prompt for username
read -p "Enter username to delete: " username

# Check if username is empty
if [ -z "$username" ]; then
    echo "Username is required!"
    log_message "ERROR: Empty username provided for deletion"
    exit 1
fi

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "User does not exist!"
    log_message "ERROR: Attempted to delete non-existent user: $username"
    exit 1
fi

# Ask for confirmation
read -p "Are you sure you want to delete user '$username'? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "User deletion cancelled."
    log_message "INFO: Deletion of user $username cancelled by administrator"
    exit 0
fi

# Ask about home directory
read -p "Do you want to keep the home directory? (y/N): " keep_home
if [[ "$keep_home" =~ ^[Yy]$ ]]; then
    remove_flag=""
    log_message "INFO: Home directory preservation requested for $username"
else
    remove_flag="-r"
    log_message "INFO: Home directory removal requested for $username"
fi

# Backup home directory before deletion
echo "Backing up home directory..."
backup_home_dir "$username"

# Delete the user
if [ -z "$remove_flag" ]; then
    sudo userdel "$username"
else
    sudo userdel $remove_flag "$username"
fi

# Check if deletion was successful
if [ $? -eq 0 ]; then
    echo "User $username deleted successfully."
    log_message "SUCCESS: User $username deleted successfully (keep_home=$keep_home)"
else
    echo "Failed to delete user $username."
    log_message "ERROR: Failed to delete user $username"
    exit 1
fi
