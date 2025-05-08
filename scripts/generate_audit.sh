#!/bin/bash

# Script to generate a comprehensive system audit report

# Default settings
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="audit_report_$TIMESTAMP.txt"
ARCHIVE_DIR="./archive"

# Default sections to include (all enabled by default)
INCLUDE_SYSTEM=true
INCLUDE_MEMORY=true
INCLUDE_NETWORK=true
INCLUDE_USERS=true
INCLUDE_SECURITY=true

# Function to display usage information
show_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -h, --help                Show this help message"
  echo "  -o, --output FILE         Specify output file (default: audit_report_TIMESTAMP.txt)"
  echo "  -e, --exclude SECTIONS    Exclude specific sections (comma-separated)"
  echo "                            Valid sections: system,memory,network,users,security"
  echo "  -i, --include SECTIONS    Include only specific sections (comma-separated)"
  echo "  -a, --archive DIR         Specify archive directory (default: ./archive)"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_usage
      exit 0
      ;;
    -o|--output)
      REPORT_FILE="$2"
      shift 2
      ;;
    -e|--exclude)
      # Parse excluded sections
      IFS=',' read -ra EXCLUDE_SECTIONS <<< "$2"
      for section in "${EXCLUDE_SECTIONS[@]}"; do
        case "$section" in
          system) INCLUDE_SYSTEM=false ;;
          memory) INCLUDE_MEMORY=false ;;
          network) INCLUDE_NETWORK=false ;;
          users) INCLUDE_USERS=false ;;
          security) INCLUDE_SECURITY=false ;;
          *) echo "Warning: Unknown section '$section'" ;;
        esac
      done
      shift 2
      ;;
    -i|--include)
      # First disable all sections
      INCLUDE_SYSTEM=false
      INCLUDE_MEMORY=false
      INCLUDE_NETWORK=false
      INCLUDE_USERS=false
      INCLUDE_SECURITY=false
      
      # Then enable only specified sections
      IFS=',' read -ra INCLUDE_SECTIONS <<< "$2"
      for section in "${INCLUDE_SECTIONS[@]}"; do
        case "$section" in
          system) INCLUDE_SYSTEM=true ;;
          memory) INCLUDE_MEMORY=true ;;
          network) INCLUDE_NETWORK=true ;;
          users) INCLUDE_USERS=true ;;
          security) INCLUDE_SECURITY=true ;;
          *) echo "Warning: Unknown section '$section'" ;;
        esac
      done
      shift 2
      ;;
    -a|--archive)
      ARCHIVE_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      show_usage
      exit 1
      ;;
  esac
done

# Create archive directory if it doesn't exist
mkdir -p "$ARCHIVE_DIR"

# Function to check command availability
check_command() {
  command -v "$1" &> /dev/null || echo "$1 command not found"
}

# Function to generate system information section
generate_system_info() {
  echo "===== SYSTEM INFORMATION ====="
  echo "Generated on: $(date)"
  echo "Hostname: $(hostname)"
  echo ""
  echo "---- System Uptime ----"
  check_command uptime && uptime || echo "uptime command not found"
  echo ""
  echo "---- OS Information ----"
  if [ -f /etc/os-release ]; then
    cat /etc/os-release | grep -E "^(NAME|VERSION)="
  else
    echo "OS information not available"
  fi
  echo ""
  echo "---- Kernel Information ----"
  check_command uname && uname -a || echo "uname command not found"
  echo ""
  echo "---- CPU Information ----"
  if [ -f /proc/cpuinfo ]; then
    grep -m1 "model name" /proc/cpuinfo
    grep -c "processor" /proc/cpuinfo | awk '{print "CPU Cores: " $1}'
  else
    echo "CPU information not available"
  fi
  echo ""
  echo "---- Disk Usage ----"
  check_command df && df -h || echo "df command not found"
  echo ""
}

# Function to generate memory information section
generate_memory_info() {
  echo "===== MEMORY INFORMATION ====="
  echo "---- Memory Usage ----"
  check_command free && free -h || echo "free command not found"
  echo ""
  echo "---- Swap Usage ----"
  check_command swapon && swapon --show || echo "swapon command not found"
  echo ""
  echo "---- Top 10 Memory-Consuming Processes ----"
  check_command ps && ps aux --sort=-%mem | head -n 11 || echo "ps command not found"
  echo ""
}

# Function to generate network information section
generate_network_info() {
  echo "===== NETWORK INFORMATION ====="
  echo "---- IP Configuration ----"
  check_command ip && ip a || echo "ip command not found"
  echo ""
  echo "---- Network Connections ----"
  check_command netstat && netstat -tuln || check_command ss && ss -tuln || echo "netstat/ss command not found"
  echo ""
  echo "---- Listening Ports ----"
  check_command lsof && lsof -i -P -n | grep LISTEN || echo "lsof command not found"
  echo ""
  echo "---- Firewall Status ----"
  if check_command ufw &> /dev/null; then
    ufw status
  elif check_command iptables &> /dev/null; then
    iptables -L -n
  else
    echo "No firewall information available"
  fi
  echo ""
}

# Function to generate user activity information section
generate_user_info() {
  echo "===== USER INFORMATION ====="
  echo "---- Currently Logged In Users ----"
  check_command who && who || echo "who command not found"
  echo ""
  echo "---- Last Logins ----"
  check_command last && last -n 10 || echo "last command not found"
  echo ""
  echo "---- Failed Login Attempts ----"
  if [ -f /var/log/auth.log ]; then
    grep "Failed password" /var/log/auth.log | tail -n 10
  elif [ -f /var/log/secure ]; then
    grep "Failed password" /var/log/secure | tail -n 10
  else
    echo "Auth logs not found or not accessible"
  fi
  echo ""
  echo "---- User Account Information ----"
  check_command getent && getent passwd | cut -d: -f1,5 | sort || echo "getent command not found"
  echo ""
  echo "---- Sudo Users ----"
  if [ -f /etc/sudoers ]; then
    grep -v "^#" /etc/sudoers | grep -v "^$" | grep "ALL"
  fi
  if [ -d /etc/sudoers.d ]; then
    grep -v "^#" /etc/sudoers.d/* 2>/dev/null | grep -v "^$" | grep "ALL"
  fi
  echo ""
}

# Function to generate security information section
generate_security_info() {
  echo "===== SECURITY INFORMATION ====="
  echo "---- Password Policy ----"
  if [ -f /etc/login.defs ]; then
    grep "^PASS_" /etc/login.defs
  else
    echo "Password policy information not available"
  fi
  echo ""
  echo "---- SUID Files ----"
  check_command find && find / -type f -perm -4000 -ls 2>/dev/null | head -n 10 || echo "find command not found"
  echo ""
  echo "---- SSH Configuration ----"
  if [ -f /etc/ssh/sshd_config ]; then
    grep -v "^#" /etc/ssh/sshd_config | grep -v "^$" | grep -E "PermitRootLogin|PasswordAuthentication|X11Forwarding"
  else
    echo "SSH configuration not found"
  fi
  echo ""
  echo "---- System Updates ----"
  if check_command apt &> /dev/null; then
    apt list --upgradable 2>/dev/null | head -n 10
  elif check_command yum &> /dev/null; then
    yum check-update --quiet | head -n 10
  else
    echo "Package manager not found"
  fi
  echo ""
}

# Generate report
{
  echo "===== SYSTEM AUDIT REPORT ====="
  echo "Generated on: $(date)"
  echo "Report file: $REPORT_FILE"
  echo ""
  
  # Include sections based on configuration
  if [ "$INCLUDE_SYSTEM" = true ]; then
    generate_system_info
  fi
  
  if [ "$INCLUDE_MEMORY" = true ]; then
    generate_memory_info
  fi
  
  if [ "$INCLUDE_NETWORK" = true ]; then
    generate_network_info
  fi
  
  if [ "$INCLUDE_USERS" = true ]; then
    generate_user_info
  fi
  
  if [ "$INCLUDE_SECURITY" = true ]; then
    generate_security_info
  fi
  
  echo "===== END OF REPORT ====="
} > "$REPORT_FILE"

echo "Audit complete. Report saved to $REPORT_FILE"

# Optionally send the report via email
read -p "Would you like to email this report? (y/n): " send_email
if [[ "$send_email" =~ ^[Yy]$ ]]; then
  read -p "Enter recipient email: " recipient
  if [ -n "$recipient" ]; then
    if [ -f "./send_report.sh" ]; then
      ./send_report.sh "$recipient" "$REPORT_FILE"
    else
      echo "send_report.sh not found. Email functionality unavailable."
    fi
  else
    echo "No recipient specified. Email not sent."
  fi
fi
