#!/bin/bash

# Usage: ./remove_students.sh 2023_fall_users.csv

USERS_CSV="$1"
ARCHIVE_DIR="$HOME/archives"
ARCHIVE_NAME="$(basename "$USERS_CSV" _users.csv).tar"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

if [ ! -f "$USERS_CSV" ]; then
    echo "Users CSV file not found!"
    exit 1
fi

mkdir -p "$ARCHIVE_DIR"
USER_HOMES=()

tail -n +2 "$USERS_CSV" | while IFS=',' read -r student_id username
do
    if [ -d "/Users/$username" ]; then
        USER_HOMES+=("/Users/$username")
    elif [ -d "/home/$username" ]; then
        USER_HOMES+=("/home/$username")
    else
        echo "Home directory for $username not found. Skipping."
    fi
done

if [ "${#USER_HOMES[@]}" -gt 0 ]; then
    tar -cvf "$ARCHIVE_PATH" "${USER_HOMES[@]}"
    ARCHIVE_SIZE=$(stat -f%z "$ARCHIVE_PATH")
    if [ "$ARCHIVE_SIZE" -gt $((1024 * 1024 * 1024)) ]; then
        echo "WARNING: Archive exceeds 1GB in size."
    fi
else
    echo "No user home directories found to archive."
fi

tail -n +2 "$USERS_CSV" | while IFS=',' read -r student_id username
do
    if id "$username" &>/dev/null; then
        if [ -d "/Users/$username" ]; then
            sudo sysadminctl -deleteUser "$username"
        elif [ -d "/home/$username" ]; then
            sudo userdel -r "$username" 2>/dev/null || sudo dscl . -delete "/Users/$username"
            sudo rm -rf "/home/$username"
        fi
        echo "Removed user: $username"
    fi
done
