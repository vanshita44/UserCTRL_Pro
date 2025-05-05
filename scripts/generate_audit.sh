
#!/bin/bash

# Script to generate a system audit report

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="audit_report_$TIMESTAMP.txt"

{
    echo "===== SYSTEM AUDIT REPORT ====="
    echo "Generated on: $(date)"
    echo ""

    echo "---- System Uptime ----"
    command -v uptime &> /dev/null && uptime || echo "uptime command not found"
    echo ""

    echo "---- Memory Usage ----"
    command -v free &> /dev/null && free -h || echo "free command not found"
    echo ""

    echo "---- IP Information ----"
    command -v ip &> /dev/null && ip a || echo "ip command not found"
    echo ""

    echo "---- Open Ports ----"
    command -v ss &> /dev/null && ss -tuln || echo "ss command not found"
    echo ""

    echo "---- Top 5 Memory-Consuming Processes ----"
    ps aux --sort=-%mem | head -n 6
    echo ""

} > "$REPORT_FILE"

echo "Audit complete. Report saved to $REPORT_FILE"

