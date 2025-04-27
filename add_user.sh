#!/bin/bash

# Ask for username and role
read -p "Enter username to add: " username
read -p "Enter role (admin/student/guest): " role

# Check if empty
if [ -z "$username" ] || [ -z "$role" ]; then
    echo "Username and role are required!"
    exit 1
fi

# Check if user already exists
if id "$username" &>/dev/null; then
    echo "User already exists!"
    exit 1
fi

# Create the user
sudo useradd "$username"

# Role-based settings
case $role in
  admin)
    sudo usermod -aG sudo "$username"
    ;;
  student)
    sudo usermod -aG students "$username"
    ;;
  guest)
    sudo usermod -aG guests "$username"
    ;;
  *)
    echo "Unknown role. No special groups assigned."
    ;;
esac

echo "User $username added successfully with role $role."

