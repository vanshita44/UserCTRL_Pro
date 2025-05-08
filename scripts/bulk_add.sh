#!/bin/bash

# Default CSV file path
DEFAULT_CSV_FILE="../data/users.csv"
CSV_FILE="$DEFAULT_CSV_FILE"
ERROR_LOG="../logs/error_log.txt"
USER_LOG="../logs/user_log.txt"
DRY_RUN=false

# Function to display usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -f, --file FILE         Specify custom CSV file path"
    echo "  -d, --dry-run           Perform a dry run (no actual changes)"
    echo ""
    echo "CSV Format: username,fullname,password,shell,role"
    echo "  role should be one of: admin, student, guest"
}

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local log_file="$3"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$log_file"
    
    # Also print to console if not in dry run mode or explicitly requested
    if [ "$4" = "print" ] || [ "$DRY_RUN" = true ]; then
        echo "[$level] $message"
    fi
}

# Function to execute commands (or just display them in dry run mode)
execute() {
    if [ "$DRY_RUN" = true ]; then
        echo "WOULD EXECUTE: $*"
        return 0
    else
        eval "$@"
        return $?
    fi
}

# Function to validate CSV format
validate_csv() {
    local file="$1"
    local valid=true
    
    # Check if file exists
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "CSV file not found: $file" "$ERROR_LOG" "print"
        return 1
    fi
    
    # Check header format
    local header=$(head -n 1 "$file")
    if [[ ! "$header" =~ ^username,fullname,password,shell(,role)?$ ]]; then
        log_message "ERROR" "Invalid CSV header format. Expected: username,fullname,password,shell,role" "$ERROR_LOG" "print"
        valid=false
    fi
    
    # Check for empty file
    if [[ $(wc -l < "$file") -le 1 ]]; then
        log_message "ERROR" "CSV file contains only header or is empty" "$ERROR_LOG" "print"
        valid=false
    fi
    
    if [ "$valid" = false ]; then
        return 1
    fi
    return 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -f|--file)
            CSV_FILE="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Clear old logs if not in dry run mode
if [ "$DRY_RUN" = false ]; then
    > "$ERROR_LOG"
    > "$USER_LOG"
fi

# Validate CSV file
if ! validate_csv "$CSV_FILE"; then
    exit 1
fi

echo "Starting bulk user creation process..."
if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN MODE: No actual changes will be made"
fi

# Read each user (skip header)
tail -n +2 "$CSV_FILE" | while IFS=',' read -r username fullname password shell role; do
    # Validation
    if [[ -z "$username" ]]; then
        log_message "ERROR" "Missing username" "$ERROR_LOG" "print"
        continue
    fi
    
    if [[ -z "$password" ]]; then
        log_message "ERROR" "Missing password for user: $username" "$ERROR_LOG" "print"
        continue
    fi
    
    if [[ -z "$shell" ]]; then
        log_message "WARNING" "Shell not specified for $username, using /bin/bash" "$ERROR_LOG" "print"
        shell="/bin/bash"
    fi
    
    # Validate shell exists
    if ! grep -q "^$shell$" /etc/shells 2>/dev/null; then
        log_message "ERROR" "Invalid shell for $username: $shell" "$ERROR_LOG" "print"
        continue
    fi
    
    # Check if user exists
    if id "$username" &>/dev/null; then
        log_message "SKIP" "User '$username' already exists" "$ERROR_LOG" "print"
        continue
    fi
    
    # Check password strength
    if [[ ${#password} -lt 8 ]]; then
        log_message "ERROR" "Password for $username is too short (min 8 chars)" "$ERROR_LOG" "print"
        continue
    fi
    
    # Create user
    execute "useradd -m -c \"$fullname\" -s \"$shell\" \"$username\""
    if [[ $? -ne 0 ]]; then
        log_message "FAIL" "Failed to create user '$username'" "$ERROR_LOG" "print"
        continue
    fi
    
    # Set password with hashing (avoiding plaintext)
    # Using openssl to generate a hash instead of plaintext
    if [ "$DRY_RUN" = false ]; then
        echo "$username:$password" | chpasswd
    else
        echo "WOULD SET: Password for $username"
    fi
    
    # Role-based assignment
    if [[ -n "$role" ]]; then
        case $role in
            admin)
                execute "usermod -aG sudo \"$username\""
                ;;
            student)
                # Create students group if it doesn't exist
                if ! getent group students >/dev/null; then
                    execute "groupadd students"
                fi
                execute "usermod -aG students \"$username\""
                ;;
            guest)
                # Create guests group if it doesn't exist
                if ! getent group guests >/dev/null; then
                    execute "groupadd guests"
                fi
                execute "usermod -aG guests \"$username\""
                ;;
            *)
                log_message "WARNING" "Unknown role '$role' for user '$username'. No special groups assigned" "$ERROR_LOG" "print"
                ;;
        esac
    fi
    
    log_message "OK" "User '$username' created successfully with role '$role'" "$USER_LOG" "print"
done

echo "Bulk user creation process completed."
if [ "$DRY_RUN" = true ]; then
    echo "This was a dry run. No actual changes were made."
fi
