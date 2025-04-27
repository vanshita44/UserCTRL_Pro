#!/bin/bash

# Prompt for username to lock
read -p "Enter username to lock: " username

# Check if username is empty
if [ -z "$username" ]; then
    echo "Username is required!"
    exit 1
fi

# Lock the user account
sudo usermod -L "$username"

echo "User $username has been locked successfully."

