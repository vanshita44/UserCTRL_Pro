#!/bin/bash

# bulk_add.sh - Script to add multiple users from a CSV file
# This script is designed to work with the UserCTRL Pro GUI

# Set up logging
LOG_DIR="../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/user_management_$(date +%Y%m%d).log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_message "Starting bulk_add.sh script"

# Default values
CSV_FILE=""
DRY_RUN=false

# Parse command line arguments
while getopts "f:d" opt; do
    case $opt in
        f)
            CSV_FILE="$OPTARG"
            ;;
        d)
            DRY_RUN=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Validate inputs
if [ -z "$CSV_FILE" ]; then
    echo "Error: CSV file is required"
    log_message "Error: CSV file is required"
    exit 1
fi

if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file $CSV_FILE does not exist"
    log_message "Error: CSV file $CSV_FILE does not exist"
    exit 1
fi

# Initialize counters
TOTAL=0
SUCCESS=0
FAILED=0

# Print header
if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN MODE - No changes will be made"
    log_message "Starting dry run for bulk user addition from $CSV_FILE"
else
    echo "LIVE MODE - Users will be created"
    log_message "Starting bulk user addition from $CSV_FILE"
fi

echo "----------------------------------------"
echo "Processing CSV file: $CSV_FILE"
echo "----------------------------------------"

# Skip the header line and process each line in the CSV file
tail -n +2 "$CSV_FILE" | while IFS=, read -r username fullname password shell role || [[ -n "$username" ]]; do
    # Increment total counter
    ((TOTAL++))
    
    # Trim whitespace
    username=$(echo "$username" | tr -d '[:space:]')
    fullname=$(echo "$fullname" | tr -d '[:space:]')
    password=$(echo "$password" | tr -d '[:space:]')
    shell=$(echo "$shell" | tr -d '[:space:]')
    role=$(echo "$role" | tr -d '[:space:]')
    
    # Set default shell if not specified
    if [ -z "$shell" ]; then
        shell="/bin/bash"
    fi
    
    # Set default role if not specified
    if [ -z "$role" ]; then
        role="student"
    fi
    
    echo "Processing user: $username"
    
    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "  - SKIPPED: User $username already exists"
        log_message "SKIPPED: User $username already exists"
        ((FAILED++))
        continue
    fi
    
    # Validate required fields
    if [ -z "$username" ] || [ -z "$password" ]; then
        echo "  - SKIPPED: Username and password are required"
        log_message "SKIPPED: Username or password missing for entry"
        ((FAILED++))
        continue
    fi
    
    # If this is a dry run, just print what would happen
    if [ "$DRY_RUN" = true ]; then
        echo "  - WOULD CREATE: User $username with role $role"
        echo "    Full Name: $fullname"
        echo "    Shell: $shell"
        ((SUCCESS++))
        continue
    fi
    
    # Add the user
    useradd -m -s "$shell" -c "$fullname" "$username"
    if [ $? -ne 0 ]; then
        echo "  - FAILED: Could not create user $username"
        log_message "FAILED: Could not create user $username"
        ((FAILED++))
        continue
    fi
    
    # Set password
    echo "$username:$password" | chpasswd
    if [ $? -ne 0 ]; then
        echo "  - FAILED: Could not set password for user $username"
        log_message "FAILED: Could not set password for user $username"
        ((FAILED++))
        # Clean up by removing the user
        userdel -r "$username" &>/dev/null
        continue
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
    
    echo "  - SUCCESS: User $username created with role $role"
    log_message "SUCCESS: User $username created with role $role"
    ((SUCCESS++))
done

# Print summary
echo "----------------------------------------"
echo "SUMMARY:"
echo "  Total processed: $TOTAL"
echo "  Successful: $SUCCESS"
echo "  Failed: $FAILED"
echo "----------------------------------------"

if [ "$DRY_RUN" = true ]; then
    log_message "Dry run completed: $SUCCESS would be created, $FAILED would fail"
else
    log_message "Bulk add completed: $SUCCESS users created, $FAILED users failed"
fi

exit 0
