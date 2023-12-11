#!/bin/bash

# This script processes a set of files in a directory,
# counts the number of lines in each file, and appends
# the result to a summary file.

# Function to echo file_name
file(){
    echo "File: $file_name, Lines: $line_count"
}

# Set the directory path
directory_path="$HOME/"

# Set the summary file
summary_file="summary.txt"

# Clear existing content in the summary file
echo -n > "$summary_file"

# Loop through each file in the directory
for file in "$directory_path"/*; do
    if [ -f "$file" ]; then
        # Get the file name
        file_name=$(basename "$file")

        # Count the number of lines in the file
        line_count=$(wc -l < "$file")

        # Display the result
        file
        # Append the result to the summary file
        file >> "$summary_file"
    fi
done

echo "Processing complete. Summary saved to $summary_file."
