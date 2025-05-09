#!/bin/bash

# generate_audit.sh - Script to generate system audit reports
# This script is designed to work with the UserCTRL Pro GUI

# Set up logging
LOG_DIR="../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/audit_$(date +%Y%m%d).log"

# Create archive directory if it doesn't exist
ARCHIVE_DIR="./archive/reports"
mkdir -p "$ARCHIVE_DIR"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_message "Starting generate_audit.sh script"

# Default values
INCLUDE_SECTIONS="system,memory,network,users,security"
OUTPUT_FILE="audit_report_$(date +%Y%m%d_%H%M%S).txt"

# Parse command line arguments
while getopts "i:o:" opt; do
    case $opt in
        i)
            INCLUDE_SECTIONS="$OPTARG"
            ;;
        o)
            OUTPUT_FILE="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Convert include sections to array
IFS=',' read -ra SECTIONS <<< "$INCLUDE_SECTIONS"

# Start generating the report
echo "Generating audit report..."
log_message "Generating audit report with sections: $INCLUDE_SECTIONS"

# Create report header
cat > "$OUTPUT_FILE" << EOF
=======================================================
           SYSTEM AUDIT REPORT
=======================================================
Date: $(date +"%Y-%m-%d %H:%M:%S")
Hostname: $(hostname)
=======================================================

EOF

# Function to add a section header
add_section_header() {
    echo -e "\n-------------------------------------------------------" >> "$OUTPUT_FILE"
    echo "  $1" >> "$OUTPUT_FILE"
    echo "-------------------------------------------------------" >> "$OUTPUT_FILE"
}

# Generate system information section
if [[ " ${SECTIONS[*]} " =~ " system " ]]; then
    add_section_header "SYSTEM INFORMATION"
    
    # OS information
    echo -e "\n-- Operating System --" >> "$OUTPUT_FILE"
    lsb_release -a 2>/dev/null >> "$OUTPUT_FILE" || cat /etc/os-release >> "$OUTPUT_FILE"
    
    # Kernel information
    echo -e "\n-- Kernel Information --" >> "$OUTPUT_FILE"
    uname -a >> "$OUTPUT_FILE"
    
    # Uptime
    echo -e "\n-- System Uptime --" >> "$OUTPUT_FILE"
    uptime >> "$OUTPUT_FILE"
    
    # Last boot
    echo -e "\n-- Last Boot --" >> "$OUTPUT_FILE"
    who -b >> "$OUTPUT_FILE"
    
    # CPU information
    echo -e "\n-- CPU Information --" >> "$OUTPUT_FILE"
    lscpu | grep -E 'Model name|Socket|Core|Thread' >> "$OUTPUT_FILE"
    
    log_message "Added system information section to report"
fi

# Generate memory information section
if [[ " ${SECTIONS[*]} " =~ " memory " ]]; then
    add_section_header "MEMORY INFORMATION"
    
    # Memory usage
    echo -e "\n-- Memory Usage --" >> "$OUTPUT_FILE"
    free -h >> "$OUTPUT_FILE"
    
    # Swap usage
    echo -e "\n-- Swap Usage --" >> "$OUTPUT_FILE"
    swapon --show >> "$OUTPUT_FILE" 2>/dev/null || echo "No swap information available" >> "$OUTPUT_FILE"
    
    # Disk usage
    echo -e "\n-- Disk Usage --" >> "$OUTPUT_FILE"
    df -h >> "$OUTPUT_FILE"
    
    log_message "Added memory information section to report"
fi

# Generate network information section
if [[ " ${SECTIONS[*]} " =~ " network " ]]; then
    add_section_header "NETWORK INFORMATION"
    
    # Network interfaces
    echo -e "\n-- Network Interfaces --" >> "$OUTPUT_FILE"
    ip a | grep -v "valid_lft" >> "$OUTPUT_FILE"
    
    # Routing table
    echo -e "\n-- Routing Table --" >> "$OUTPUT_FILE"
    ip route >> "$OUTPUT_FILE"
    
    # Open ports
    echo -e "\n-- Open Ports --" >> "$OUTPUT_FILE"
    ss -tuln >> "$OUTPUT_FILE"
    
    # DNS configuration
    echo -e "\n-- DNS Configuration --" >> "$OUTPUT_FILE"
    cat /etc/resolv.conf >> "$OUTPUT_FILE"
    
    log_message "Added network information section to report"
fi

# Generate users information section
if [[ " ${SECTIONS[*]} " =~ " users " ]]; then
    add_section_header "USER INFORMATION"
    
    # Current users
    echo -e "\n-- Currently Logged In Users --" >> "$OUTPUT_FILE"
    who >> "$OUTPUT_FILE"
    
    # Last logins
    echo -e "\n-- Last Logins --" >> "$OUTPUT_FILE"
    last -n 10 >> "$OUTPUT_FILE"
    
    # User accounts
    echo -e "\n-- User Accounts (UID >= 1000) --" >> "$OUTPUT_FILE"
    awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | sort >> "$OUTPUT_FILE"
    
    # User groups
    echo -e "\n-- User Groups --" >> "$OUTPUT_FILE"
    cat /etc/group | grep -v "^#" | sort >> "$OUTPUT_FILE"
    
    log_message "Added user information section to report"
fi

# Generate security information section
if [[ " ${SECTIONS[*]} " =~ " security " ]]; then
    add_section_header "SECURITY INFORMATION"
    
    # Failed login attempts
    echo -e "\n-- Failed Login Attempts --" >> "$OUTPUT_FILE"
    grep "Failed password" /var/log/auth.log 2>/dev/null | tail -n 10 >> "$OUTPUT_FILE" || echo "No failed login information available" >> "$OUTPUT_FILE"
    
    # SSH configuration
    echo -e "\n-- SSH Configuration --" >> "$OUTPUT_FILE"
    grep -v "^#" /etc/ssh/sshd_config 2>/dev/null | grep -v "^$" >> "$OUTPUT_FILE" || echo "No SSH configuration available" >> "$OUTPUT_FILE"
    
    # Firewall status
    echo -e "\n-- Firewall Status --" >> "$OUTPUT_FILE"
    ufw status 2>/dev/null >> "$OUTPUT_FILE" || iptables -L 2>/dev/null >> "$OUTPUT_FILE" || echo "No firewall information available" >> "$OUTPUT_FILE"
    
    # SUDO users
    echo -e "\n-- Sudo Users --" >> "$OUTPUT_FILE"
    grep -v "^#" /etc/sudoers 2>/dev/null | grep -v "^$" >> "$OUTPUT_FILE" || echo "No sudo information available" >> "$OUTPUT_FILE"
    
    log_message "Added security information section to report"
fi

# Add report footer
cat >> "$OUTPUT_FILE" << EOF

=======================================================
           END OF REPORT
=======================================================
Generated by: UserCTRL Pro
Date: $(date +"%Y-%m-%d %H:%M:%S")
=======================================================
EOF

# Archive a copy of the report
cp "$OUTPUT_FILE" "$ARCHIVE_DIR/"

echo "Audit report generated: $OUTPUT_FILE"
log_message "Audit report generated: $OUTPUT_FILE"

exit 0
