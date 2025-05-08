#!/bin/bash

# Define log file
LOG_FILE="../logs/user_log.txt"

# Ensure log directory exists
mkdir -p $(dirname "$LOG_FILE")

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Display usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help                 Show this help message"
    echo "  -u, --unlock               Unlock user instead of locking"
    echo "  -e, --expire DAYS          Set account expiration (days from today)"
    echo "  -r, --reason \"REASON\"      Specify reason for locking/unlocking"
}

# Parse command line arguments
UNLOCK=false
EXPIRE_DAYS=""
REASON=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -u|--unlock)
            UNLOCK=true
            shift
            ;;
        -e|--expire)
            EXPIRE_DAYS="$2"
            shift 2
            ;;
        -r|--reason)
            REASON="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Prompt for username
read -p "Enter username to $([ "$UNLOCK" = true ] && echo "unlock" || echo "lock"): " username

# Check if username is empty
if [ -z "$username" ]; then
    echo "Username is required!"
    log_message "ERROR: Empty username provided for $([ "$UNLOCK" = true ] && echo "unlock" || echo "lock") operation"
    exit 1
fi

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "User does not exist!"
    log_message "ERROR: Attempted to $([ "$UNLOCK" = true ] && echo "unlock" || echo "lock") non-existent user: $username"
    exit 1
fi

# If no reason provided, prompt for it
if [ -z "$REASON" ]; then
    read -p "Enter reason for $([ "$UNLOCK" = true ] && echo "unlocking" || echo "locking") (optional): " REASON
fi

# Lock or unlock the user account
if [ "$UNLOCK" = true ]; then
    # Unlock user
    sudo usermod -U "$username"
    if [ $? -eq 0 ]; then
        echo "User $username has been unlocked successfully."
        log_message "SUCCESS: User $username unlocked. Reason: ${REASON:-No reason provided}"
    else
        echo "Failed to unlock user $username."
        log_message "ERROR: Failed to unlock user $username"
        exit 1
    fi
else
    # Lock user
    sudo usermod -L "$username"
    if [ $? -eq 0 ]; then
        echo "User $username has been locked successfully."
        log_message "SUCCESS: User $username locked. Reason: ${REASON:-No reason provided}"
    else
        echo "Failed to lock user $username."
        log_message "ERROR: Failed to lock user $username"
        exit 1
    fi
fi

# Set expiration date if specified
if [ -n "$EXPIRE_DAYS" ]; then
    # Calculate expiration date
    if [ "$EXPIRE_DAYS" = "1" ]; then
        # Special case: completely disable account (Jan 1, 1970)
        sudo usermod -e 1 "$username"
        echo "User account completely disabled (expiration set to epoch)."
        log_message "INFO: User $username account completely disabled with epoch expiration"
    else
        # Regular expiration date calculation
        EXPIRE_DATE=$(date -d "+$EXPIRE_DAYS days" +%Y-%m-%d)
        sudo usermod -e "$EXPIRE_DATE" "$username"
        echo "Account expiration set to $EXPIRE_DATE."
        log_message "INFO: User $username expiration set to $EXPIRE_DATE"
    fi
fi

# Display account status
echo "Current account status:"
sudo passwd -S "$username"
