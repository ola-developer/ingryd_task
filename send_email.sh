#!/bin/bash

# Prompt user for email subject
read -p "Enter email subject: " subject
subject=$(echo "$subject" | tr -s ' ')

# Prompt user for the file to attach
read -p "Enter the path to the file to attach: " file
file=$(echo "$file" | tr -s ' ')

# Expand ~ to the actual home directory path
file=$(readlink -m "$file")

# Prompt user for recipient's email address
read -p "Enter recipient's email address: " recipient
recipient=$(echo "$recipient" | tr -s ' ')

# Check if all required fields are provided
if [ -z "$subject" ] || [ -z "$file" ] || [ -z "$recipient" ]; then
    echo "Error: All fields must be provided."
    exit 1
fi

# Use mutt to send the email
if echo "Subject: $subject" | mutt -s "$subject" -a "$file" -- "$recipient"; then
    echo "Email sent successfully"
else
    echo "Email sending failed"
fi

