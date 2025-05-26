#!/bin/bash

# Usage: ./create_students.sh 2023_fall.csv

CSV_FILE="$1"
USERS_CSV="${CSV_FILE%.csv}_users.csv"
DEFAULT_PASSWORD="ChangeMe123"
POLICY_FILE="POLICY.md"
GROUP="students"

if [ ! -f "$CSV_FILE" ]; then
    echo "CSV file not found!"
    exit 1
fi

# Create group if it doesn't exist
if ! dscl . -read /Groups/$GROUP &>/dev/null; then
    sudo dscl . -create /Groups/$GROUP
fi

echo "student_id,username" > "$USERS_CSV"

tail -n +2 "$CSV_FILE" | while IFS=',' read -r student_id last_name first_name
do
    first_initial=$(echo "$first_name" | cut -c1 | tr '[:upper:]' '[:lower:]')
    lname=$(echo "$last_name" | tr '[:upper:]' '[:lower:]')
    username="${first_initial}${lname}${student_id}"

    if ! id "$username" &>/dev/null; then
        sudo sysadminctl -addUser "$username" -fullName "$first_name $last_name" -password "$DEFAULT_PASSWORD"
        sudo dscl . -append /Groups/$GROUP GroupMembership "$username"
    fi

    USER_HOME="/Users/$username"
    sudo -u "$username" mkdir -p "$USER_HOME/documents" "$USER_HOME/code"
    sudo cp "$POLICY_FILE" "$USER_HOME/POLICY.md"
    sudo chown "$username" "$USER_HOME/POLICY.md"

    echo "$student_id,$username" >> "$USERS_CSV"
done
