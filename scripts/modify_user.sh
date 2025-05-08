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
    echo "  -u, --username USERNAME    Specify username to modify"
    echo "  -n, --new-name NEW_NAME    Change username"
    echo "  -s, --shell SHELL          Change login shell"
    echo "  -d, --home-dir DIR         Change home directory"
    echo "  -m, --move-home            Move contents to new home directory"
    echo "  -g, --group GROUP          Change primary group"
    echo "  -G, --groups GROUPS        Set supplementary groups (comma-separated)"
    echo "  -a, --append               Append to supplementary groups instead of replacing"
}

# Parse command line arguments or use interactive mode
if [ $# -gt 0 ]; then
    # Command-line mode
    USERNAME=""
    NEW_USERNAME=""
    SHELL=""
    HOME_DIR=""
    MOVE_HOME=false
    PRIMARY_GROUP=""
    GROUPS=""
    APPEND=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -u|--username)
                USERNAME="$2"
                shift 2
                ;;
            -n|--new-name)
                NEW_USERNAME="$2"
                shift 2
                ;;
            -s|--shell)
                SHELL="$2"
                shift 2
                ;;
            -d|--home-dir)
                HOME_DIR="$2"
                shift 2
                ;;
            -m|--move-home)
                MOVE_HOME=true
                shift
                ;;
            -g|--group)
                PRIMARY_GROUP="$2"
                shift 2
                ;;
            -G|--groups)
                GROUPS="$2"
                shift 2
                ;;
            -a|--append)
                APPEND=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
else
    # Interactive mode
    read -p "Enter username to modify: " USERNAME
fi

# Check if username is empty
if [ -z "$USERNAME" ]; then
    echo "Username is required!"
    log_message "ERROR: Empty username provided for modification"
    exit 1
fi

# Check if user exists
if ! id "$USERNAME" &>/dev/null; then
    echo "User does not exist!"
    log_message "ERROR: Attempted to modify non-existent user: $USERNAME"
    exit 1
fi

# If in interactive mode, prompt for modifications
if [ $# -eq 0 ]; then
    echo "Select modification to perform:"
    echo "1) Change username"
    echo "2) Change shell"
    echo "3) Change home directory"
    echo "4) Change primary group"
    echo "5) Add to groups"
    echo "6) Remove from groups"
    read -p "Enter option (1-6): " OPTION

    case $OPTION in
        1)
            read -p "Enter new username: " NEW_USERNAME
            ;;
        2)
            read -p "Enter new shell (e.g., /bin/bash): " SHELL
            ;;
        3)
            read -p "Enter new home directory: " HOME_DIR
            read -p "Move contents to new home directory? (y/N): " MOVE_CHOICE
            if [[ "$MOVE_CHOICE" =~ ^[Yy]$ ]]; then
                MOVE_HOME=true
            fi
            ;;
        4)
            read -p "Enter new primary group: " PRIMARY_GROUP
            ;;
        5)
            read -p "Enter groups to add (comma-separated): " GROUPS
            APPEND=true
            ;;
        6)
            read -p "Enter groups to remove (comma-separated): " GROUPS
            # We'll handle removal differently
            ;;
        *)
            echo "Invalid option!"
            exit 1
            ;;
    esac
fi

# Prepare usermod command
USERMOD_CMD="sudo usermod"
CHANGES_MADE=false
CHANGES_DESC=""

# Change username if specified
if [ -n "$NEW_USERNAME" ]; then
    USERMOD_CMD="$USERMOD_CMD -l $NEW_USERNAME"
    CHANGES_MADE=true
    CHANGES_DESC="$CHANGES_DESC username changed to $NEW_USERNAME;"
fi

# Change shell if specified
if [ -n "$SHELL" ]; then
    # Validate shell exists in /etc/shells
    if grep -q "^$SHELL$" /etc/shells 2>/dev/null; then
        USERMOD_CMD="$USERMOD_CMD -s $SHELL"
        CHANGES_MADE=true
        CHANGES_DESC="$CHANGES_DESC shell changed to $SHELL;"
    else
        echo "Error: Shell $SHELL is not valid. Check /etc/shells for valid shells."
        log_message "ERROR: Invalid shell specified for $USERNAME: $SHELL"
        exit 1
    fi
fi

# Change home directory if specified
if [ -n "$HOME_DIR" ]; then
    if [ "$MOVE_HOME" = true ]; then
        USERMOD_CMD="$USERMOD_CMD -d $HOME_DIR -m"
        CHANGES_MADE=true
        CHANGES_DESC="$CHANGES_DESC home directory moved to $HOME_DIR;"
    else
        USERMOD_CMD="$USERMOD_CMD -d $HOME_DIR"
        CHANGES_MADE=true
        CHANGES_DESC="$CHANGES_DESC home directory changed to $HOME_DIR (without moving contents);"
    fi
fi

# Change primary group if specified
if [ -n "$PRIMARY_GROUP" ]; then
    # Check if group exists
    if getent group "$PRIMARY_GROUP" >/dev/null; then
        USERMOD_CMD="$USERMOD_CMD -g $PRIMARY_GROUP"
        CHANGES_MADE=true
        CHANGES_DESC="$CHANGES_DESC primary group changed to $PRIMARY_GROUP;"
    else
        echo "Error: Group $PRIMARY_GROUP does not exist."
        log_message "ERROR: Non-existent group specified for $USERNAME: $PRIMARY_GROUP"
        exit 1
    fi
fi

# Handle supplementary groups
if [ -n "$GROUPS" ]; then
    # For group removal (option 6 in interactive mode)
    if [ "$OPTION" = "6" ]; then
        CURRENT_GROUPS=$(id -Gn "$USERNAME" | tr ' ' ',')
        IFS=',' read -ra REMOVE_GROUPS <<< "$GROUPS"
        IFS=',' read -ra CURRENT_GROUP_ARRAY <<< "$CURRENT_GROUPS"
        
        NEW_GROUPS=()
        for group in "${CURRENT_GROUP_ARRAY[@]}"; do
            KEEP=true
            for remove_group in "${REMOVE_GROUPS[@]}"; do
                if [ "$group" = "$remove_group" ]; then
                    KEEP=false
                    break
                fi
            done
            if [ "$KEEP" = true ]; then
                NEW_GROUPS+=("$group")
            fi
        done
        
        if [ ${#NEW_GROUPS[@]} -gt 0 ]; then
            GROUPS=$(IFS=,; echo "${NEW_GROUPS[*]}")
            USERMOD_CMD="$USERMOD_CMD -G $GROUPS"
            CHANGES_MADE=true
            CHANGES_DESC="$CHANGES_DESC removed from groups: $GROUPS;"
        else
            echo "Error: Cannot remove all groups. User must belong to at least one group."
            log_message "ERROR: Attempted to remove all groups from $USERNAME"
            exit 1
        fi
    else
        # For adding groups
        if [ "$APPEND" = true ]; then
            USERMOD_CMD="$USERMOD_CMD -a -G $GROUPS"
            CHANGES_MADE=true
            CHANGES_DESC="$CHANGES_DESC added to groups: $GROUPS;"
        else
            USERMOD_CMD="$USERMOD_CMD -G $GROUPS"
            CHANGES_MADE=true
            CHANGES_DESC="$CHANGES_DESC supplementary groups set to: $GROUPS;"
        fi
    fi
fi

# Execute the command if changes were specified
if [ "$CHANGES_MADE" = true ]; then
    $USERMOD_CMD "$USERNAME"
    
    if [ $? -eq 0 ]; then
        echo "User $USERNAME modified successfully."
        log_message "SUCCESS: Modified user $USERNAME: $CHANGES_DESC"
        
        # Show updated user information
        echo "Updated user information:"
        id "$USERNAME"
    else
        echo "Failed to modify user $USERNAME."
        log_message "ERROR: Failed to modify user $USERNAME: $CHANGES_DESC"
        exit 1
    fi
else
    echo "No changes specified for user $USERNAME."
    log_message "INFO: No changes specified for user $USERNAME"
fi
