#!/bin/bash

read -p "Enter username to delete: " username

if [ -z "$username" ]; then
    echo "Username is required!"
    exit 1
fi

if ! id "$username" &>/dev/null; then
    echo "User does not exist!"
    exit 1
fi

sudo userdel -r "$username"

echo "User $username deleted successfully."
