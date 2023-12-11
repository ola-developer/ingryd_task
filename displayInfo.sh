#!/bin/bash

# Function to display file information
displayFileInfo() {
    local filename=$1

    # Check if the file exists
    if [ -e "$filename" ]; then
        # File type
        file_type=$(file -b "$filename")

        # File size
        file_size=$(du -h "$filename" | cut -f1)

        # File permissions
        file_permissions=$(ls -l "$filename" | cut -d ' ' -f1)

        # Display information
        echo "File Information for: $filename"
        echo "Type: $file_type"
        echo "Size: $file_size"
        echo "Permissions: $file_permissions"
    else
        echo "Error: File '$filename' not found."
    fi
}

# Check if a filename is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Get the filename from the command line argument
filename=$1

# Call the function to display information
displayFileInfo "$filename"

