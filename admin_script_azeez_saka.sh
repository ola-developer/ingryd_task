#!/bin/bash

# Author: 		    Azeez	Saka
# Created: 		    23rd November 2023
# Last Modified: 	23rd November 2023
# Description:
#        Create compressed backups of important files found in ~/ingrydDocs
#        to a regular backup destination.
#        If the files in the source directory have not changed since the
#        last backup, backup will be skip

#        Tabular Reports on the following key System Metrics that goes back a whole Week.
#	            CPU Usage
#	            Memory Usage
#	            Disk Space
#	            Network Statistics

#        Oracle Schema backup specify at runtime to a Remote destination and run on Oracle

#        A final Tabulated Reports on all Tasks forward to the mail below:
#        martin.mato@ingrydacademy.com

# Usage:
#        ./admin_script.sh



# Function to prompt the user for a path and validate it
prompt_for_path() {
    local placeholder="$1"
    local user_prompt="Enter the path for $placeholder:"
    read -p "$user_prompt " user_input

    # Check if the input is empty
    if [ -z "$user_input" ]; then
        echo "Error: Path for $placeholder cannot be empty. Please provide a valid path."
        exit 1
    fi

    echo "$user_input"
}

# Task 1: Backup important files
backup_source="$HOME/ingrydDocs"
backup_destination="$HOME"
backup_file="backup_$(date '+%Y%m%d%H%M%S').tar.gz"

# Create backup destination if it doesn't exist
mkdir -p "$backup_destination"

# Check if files have changed since the last backup
if rsync -a --checksum --delete "$backup_source" "$backup_destination"; then
    # Files have changed, perform the backup
    tar -czf "$backup_destination/$backup_file" "$backup_source"
    echo "Backup completed successfully."
else
    echo "No changes in files since the last backup. Skipping backup."
fi

# Task 2: System Metrics Report
system_metrics_report=$(prompt_for_path "system_metrics_report")
echo -e "Date\tCPU Usage (%)\tMemory Usage (%)\tDisk Space Usage (%)\tNetwork Statistics" > "$system_metrics_report"
for ((day = 6; day >= 0; day--)); do
    date_format=$(date -d "$day days ago" '+%Y-%m-%d')
    cpu_usage=$(sar -u -f "/var/log/sa/sa$date_format" | awk '$1 == "Average:" {print 100 - $NF}')
    memory_usage=$(sar -r -f "/var/log/sa/sa$date_format" | awk '$1 == "Average:" {print $4}')
    disk_usage=$(df -h --total | awk '$1 == "total" {print $5}' | tr -d '%')
    network_stats=$(sar -n DEV -f "/var/log/sa/sa$date_format" | awk '$1 == "Average:" {print $2,$5}')

    echo -e "$date_format\t$cpu_usage\t$memory_usage\t$disk_usage\t$network_stats" >> "$system_metrics_report"
done

# Task 3: Backup Oracle Schema
echo "Enter Oracle Schema Name:"
read oracle_schema_name
oracle_backup_destination=$(prompt_for_path "oracle_backup_destination")
oracle_backup_file="oracle_backup_$(date '+%Y%m%d%H%M%S').dmp"

# Backup Oracle Schema
exp "$oracle_schema_name" file="$oracle_backup_destination/$oracle_backup_file"

# Task 4: Final Report and Email
final_report=$(prompt_for_path "final_report")
echo -e "\nOracle Backup Information:\nSchema Name: $oracle_schema_name\nBackup File: $oracle_backup_file" >> "$system_metrics_report"
cat "$system_metrics_report" > "$final_report"

# Mail the final report
mail -s "Weekly System Report" martin.mato@ingrydacademy.com < "$final_report"

# Cleanup: Remove temporary files
rm "$system_metrics_report" "$final_report"
