#!/bin/bash

CSV_FILE="../data/users.csv"
ERROR_LOG="../logs/error_log.txt"
USER_LOG="../logs/user_log.txt"

# Clear old logs
> "$ERROR_LOG"
> "$USER_LOG"

# Check if CSV exists
if [[ ! -f "$CSV_FILE" ]]; then
    echo "[ERROR] CSV file not found: $CSV_FILE" | tee -a "$ERROR_LOG"
    exit 1
fi

# Read each user (skip header)
tail -n +2 "$CSV_FILE" | while IFS=',' read -r username fullname password shell; do
    # Validation
    if [[ -z "$username" || -z "$password" || -z "$shell" ]]; then
        echo "[ERROR] Missing fields for user: $username" | tee -a "$ERROR_LOG"
        continue
    fi

    # Check if user exists
    if id "$username" &>/dev/null; then
        echo "[SKIP] User '$username' already exists." | tee -a "$ERROR_LOG"
        continue
    fi

    # Create user
    useradd -m -c "$fullname" -s "$shell" "$username"
    echo "$username:$password" | chpasswd

    if [[ $? -eq 0 ]]; then
        echo "[OK] User '$username' created successfully." | tee -a "$USER_LOG"
    else
        echo "[FAIL] Failed to create user '$username'." | tee -a "$ERROR_LOG"
    fi
done
