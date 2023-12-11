#!/bin/bash

# Author:            Azeez Saka
# Created:           23rd November 2023
# Last Modified:     30th November 2023
# Description:
#   Create compressed backups of important files found in ~/ingrydDocs
#   to a regular backup destination.
#   If the files in the source directory have not changed since the
#   last backup, backup will be skipped.

#   Tabular Reports on the following key System Metrics that go back a whole Week.
#       CPU Usage
#       Memory Usage
#       Disk Space
#       Network Statistics

#   Oracle Schema backup specified at runtime to a Remote destination and run on Oracle

#   A final Tabulated Reports on all Tasks forwarded to the mail below:
#   martin.mato@ingrydacademy.com

# Usage:
#   ./admin_script.sh

# Task 1: Backup important files
backup_source="$HOME/ingrydDocs"
backup_destination="$HOME/backups"
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
system_metrics_report="$HOME/system_metrics_report.txt"  # Set a default path
echo -e "Date\tCPU Usage (%)\tMemory Usage (%)\tDisk Space Usage (%)\tNetwork Statistics" > "$system_metrics_report"
for ((day = 6; day >= 0; day--)); do
    date_format=$(date -d "$day days ago" '+%Y-%m-%d')
    sar_log_file="/var/log/sa/sa$date_format"

    # Check if SAR log file exists
    if [ -f "$sar_log_file" ]; then
        cpu_usage=$(sar -u -f "$sar_log_file" | awk '$1 == "Average:" {print 100 - $NF}')
        memory_usage=$(sar -r -f "$sar_log_file" | awk '$1 == "Average:" {print $4}')
        disk_usage=$(df -h --total | awk '$1 == "total" {print $5}' | tr -d '%')
        network_stats=$(sar -n DEV -f "$sar_log_file" | awk '$1 == "Average:" {print $2,$5}')

        echo -e "$date_format\t$cpu_usage\t$memory_usage\t$disk_usage\t$network_stats" >> "$system_metrics_report"
    else
        echo "Warning: SAR log file not found for $date_format. Skipping metrics for this date." >&2
    fi
done

# Task 3: Backup Oracle Schema
echo "Enter Oracle Schema Name:"
read oracle_schema_name
oracle_backup_destination="$HOME/oracle_backups"  # Set a default path
mkdir -p "$oracle_backup_destination"
oracle_backup_file="oracle_backup_$(date '+%Y%m%d%H%M%S').dmp"

# Backup Oracle Schema using Data Pump
expdp "$oracle_schema_name" dumpfile="$oracle_backup_destination/$oracle_backup_file"
expStat=$?

if [ $expStat -eq 0 ]; then
    echo "Oracle Schema backup completed successfully."
else
    echo "Oracle Schema backup failed. Exit status: $expStat" >&2
fi

# Task 4: Final Report and Email
final_report="$HOME/final_report.txt"
echo -e "\nOracle Backup Information:\nSchema Name: $oracle_schema_name\nBackup File: $oracle_backup_file" >> "$system_metrics_report"
cat "$system_metrics_report" > "$final_report"

# Compress backups
tar -czf "$backup_destination/backups_$(date '+%Y%m%d%H%M%S').tar.gz" "$backup_destination"

# Mail the final report
echo "Sending mail now"
mutt -s "Weekly System Report" -a "$final_report" -- martin.mato@ingrydacademy.com < /dev/null

# Check if mail was sent successfully
muttStat=$?
if [ $muttStat -eq 0 ]; then
    echo "Mail sent successfully"
else
    echo "Mail sending failed" >&2
fi

# Cleanup: Remove temporary files
rm "$system_metrics_report" "$final_report" "$backup_destination/$backup_file"
