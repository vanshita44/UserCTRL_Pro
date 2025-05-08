#!/usr/bin/env bash

# Define constants and defaults
LOG_FILE="../logs/email_log.txt"
ARCHIVE_DIR="../archive/reports"
DEFAULT_SUBJECT="System Audit Report"

# Create directories if they don't exist
mkdir -p "$(dirname "$LOG_FILE")" "$ARCHIVE_DIR"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# Function to display usage information
show_usage() {
    echo "Usage: $0 [options] recipient@example.com report_file.txt"
    echo "Options:"
    echo "  -h, --help                 Show this help message"
    echo "  -s, --subject SUBJECT      Specify email subject (default: System Audit Report)"
    echo "  -a, --archive-dir DIR      Specify custom archive directory"
}

# Function to validate email address
validate_email() {
    local email="$1"
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        log_message "ERROR: Invalid email format: $email"
        return 1
    fi
    return 0
}

# Parse command line arguments
SUBJECT="$DEFAULT_SUBJECT"
RECIPIENT=""
REPORT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -s|--subject)
            SUBJECT="$2"
            shift 2
            ;;
        -a|--archive-dir)
            ARCHIVE_DIR="$2"
            shift 2
            ;;
        -*)
            log_message "ERROR: Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$RECIPIENT" ]; then
                RECIPIENT="$1"
            elif [ -z "$REPORT_FILE" ]; then
                REPORT_FILE="$1"
            else
                log_message "ERROR: Too many arguments"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if report file is specified
if [ -z "$REPORT_FILE" ]; then
    log_message "ERROR: No report file specified"
    show_usage
    exit 1
fi

# Check if report file exists
if [ ! -f "$REPORT_FILE" ]; then
    log_message "ERROR: Report file not found: $REPORT_FILE"
    exit 1
fi

# Check if recipient is specified
if [ -z "$RECIPIENT" ]; then
    log_message "ERROR: No recipient specified"
    show_usage
    exit 1
fi

# Validate email address
if ! validate_email "$RECIPIENT"; then
    log_message "ERROR: Invalid email address: $RECIPIENT"
    exit 1
fi

# Send the email
log_message "INFO: Sending report to: $RECIPIENT"
mail -s "$SUBJECT" "$RECIPIENT" < "$REPORT_FILE"

# Check if mail command was successful
if [ $? -eq 0 ]; then
    log_message "SUCCESS: Email sent successfully to $RECIPIENT"
else
    log_message "ERROR: Failed to send email"
    exit 1
fi

# Create archive folder structure by date
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
ARCHIVE_PATH="$ARCHIVE_DIR/$YEAR/$MONTH/$DAY"
mkdir -p "$ARCHIVE_PATH"

# Copy report to archive
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_BASENAME=$(basename "$REPORT_FILE")
ARCHIVE_NAME="$ARCHIVE_PATH/${REPORT_BASENAME%.*}_$TIMESTAMP.txt"

cp "$REPORT_FILE" "$ARCHIVE_NAME"

if [ $? -eq 0 ]; then
    log_message "SUCCESS: Report archived as $ARCHIVE_NAME"
    exit 0
else
    log_message "ERROR: Failed to archive report"
    exit 1
fi
