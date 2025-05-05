#!/bin/bash

# Usage: ./send_report.sh recipient@example.com audit_report_*.txt

if [ $# -lt 2 ]; then
  echo "Usage: $0 recipient@example.com report_file.txt"
  exit 1
fi

recipient="$1"
report_file="$2"
subject="System Audit Report"
body="Please find the attached system audit report."

# Send the email
mail -s "$subject" "$recipient" < "$report_file"

# Check if mail sent (optional check can be added here)

# Create archive folder if it doesn't exist
mkdir -p archive

# Move and rename report to archive/
timestamp=$(date +%Y%m%d_%H%M%S)
archive_name="archive/$(basename "$report_file" .txt)_$timestamp.txt"
mv "$report_file" "$archive_name"

echo "Report archived as $archive_name"

