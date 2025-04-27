#!/bin/bash

# Prompt for username to modify
read -p "Enter username to modify: " username

# Check if username is empty
if [ -z "$username" ]; then
    echo "Username is required!"
    exit 1
fi

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "User does not exist!"
    exit 1
fi

# Prompt for new username
read -p "Enter new username: " new_username

# Modify the username
sudo usermod -l "$new_username" "$username"

echo "Username has been changed to $new_username."

