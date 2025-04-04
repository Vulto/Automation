#!/bin/bash

# Create output directory with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="system_report_$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

echo "Generating detailed system report..."
echo "This may take a few moments..."

# Function to add section headers
add_section() {
    echo "============================================" >> "$2"
    echo "$1" >> "$2"
    echo "============================================" >> "$2"
    echo "" >> "$2"
}

# Boot Process Information
BOOT_FILE="$OUTPUT_DIR/boot_info.txt"
add_section "BOOT PROCESS INFORMATION" "$BOOT_FILE"
dmesg > "$BOOT_FILE" 2>/dev/null || echo "dmesg requires root privileges" >> "$BOOT_FILE"
systemctl list-units --type=service --state=active >> "$BOOT_FILE"

# CPU Information
CPU_FILE="$OUTPUT_DIR/cpu_info.txt"
add_section "CPU INFORMATION" "$CPU_FILE"
lscpu >> "$CPU_FILE"
cat /proc/cpuinfo >> "$CPU_FILE"
echo -e "\nCurrent CPU Usage:" >> "$CPU_FILE"
mpstat 1 3 >> "$CPU_FILE" 2>/dev/null || echo "mpstat requires sysstat package" >> "$CPU_FILE"

# Hard Disk Information
DISK_FILE="$OUTPUT_DIR/disk_info.txt"
add_section "HARD DISK INFORMATION" "$DISK_FILE"
lsblk -f >> "$DISK_FILE"
echo -e "\nDisk Space Usage:" >> "$DISK_FILE"
df -h >> "$DISK_FILE"
echo -e "\nPartition Information:" >> "$DISK_FILE"
fdisk -l >> "$DISK_FILE" 2>/dev/null || echo "fdisk requires root privileges" >> "$DISK_FILE"
echo -e "\nSMART Data (first disk):" >> "$DISK_FILE"
smartctl -a /dev/sda >> "$DISK_FILE" 2>/dev/null || echo "smartctl requires root privileges or smartmontools" >> "$DISK_FILE"

# Memory Information
MEM_FILE="$OUTPUT_DIR/memory_info.txt"
add_section "MEMORY INFORMATION" "$MEM_FILE"
free -h >> "$MEM_FILE"
echo -e "\nDetailed Memory Info:" >> "$MEM_FILE"
cat /proc/meminfo >> "$MEM_FILE"
echo -e "\nMemory Slots:" >> "$MEM_FILE"
dmidecode -t memory >> "$MEM_FILE" 2>/dev/null || echo "dmidecode requires root privileges" >> "$MEM_FILE"

# Network Information
NET_FILE="$OUTPUT_DIR/network_info.txt"
add_section "NETWORK INFORMATION" "$NET_FILE"
ip addr show >> "$NET_FILE"
echo -e "\nRouting Table:" >> "$NET_FILE"
ip route show >> "$NET_FILE"
echo -e "\nNetwork Interfaces:" >> "$NET_FILE"
ifconfig -a >> "$NET_FILE" 2>/dev/null || ip link show >> "$NET_FILE"
echo -e "\nOpen Ports:" >> "$NET_FILE"
netstat -tuln >> "$NET_FILE" 2>/dev/null || ss -tuln >> "$NET_FILE"
echo -e "\nNetwork Statistics:" >> "$NET_FILE"
netstat -s >> "$NET_FILE" 2>/dev/null || cat /proc/net/dev >> "$NET_FILE"

# System Logs
LOG_FILE="$OUTPUT_DIR/system_logs.txt"
add_section "SYSTEM LOGS" "$LOG_FILE"
journalctl -b -n 1000 >> "$LOG_FILE" 2>/dev/null || echo "journalctl requires root privileges" >> "$LOG_FILE"
echo -e "\nLast 100 lines of syslog:" >> "$LOG_FILE"
tail -n 100 /var/log/syslog >> "$LOG_FILE" 2>/dev/null || tail -n 100 /var/log/messages >> "$LOG_FILE" 2>/dev/null

# Systemd Services
SERVICE_FILE="$OUTPUT_DIR/systemd_services.txt"
add_section "SYSTEMD SERVICES" "$SERVICE_FILE"
systemctl list-units --type=service --all >> "$SERVICE_FILE"
echo -e "\nFailed Services:" >> "$SERVICE_FILE"
systemctl list-units --state=failed >> "$SERVICE_FILE"

# Largest Folders and Files
SIZE_FILE="$OUTPUT_DIR/large_items.txt"
add_section "TOP 10 LARGEST FOLDERS AND FILES" "$SIZE_FILE"
echo "Top 10 Largest Directories:" >> "$SIZE_FILE"
du -ah / 2>/dev/null | sort -rh | head -n 10 >> "$SIZE_FILE"
echo -e "\nTop 10 Largest Files:" >> "$SIZE_FILE"
find / -type f -exec du -h {} + 2>/dev/null | sort -rh | head -n 10 >> "$SIZE_FILE"

# Most Intense Processes
PROC_FILE="$OUTPUT_DIR/top_processes.txt"
add_section "TOP 10 MOST INTENSE PROCESSES" "$PROC_FILE"
ps aux --sort=-%cpu | head -n 11 >> "$PROC_FILE"
echo -e "\nReal-time monitoring (3 seconds):" >> "$PROC_FILE"
top -b -n 1 >> "$PROC_FILE"

# Create a summary file
SUMMARY_FILE="$OUTPUT_DIR/summary.txt"
add_section "SYSTEM SUMMARY" "$SUMMARY_FILE"
uname -a >> "$SUMMARY_FILE"
echo -e "\nOS Release:" >> "$SUMMARY_FILE"
cat /etc/os-release >> "$SUMMARY_FILE"
echo -e "\nUptime:" >> "$SUMMARY_FILE"
uptime >> "$SUMMARY_FILE"
echo -e "\nCurrent Users:" >> "$SUMMARY_FILE"
who >> "$SUMMARY_FILE"

# Compress all reports
tar -czf "system_report_$TIMESTAMP.tar.gz" "$OUTPUT_DIR"

echo "System report generated successfully!"
echo "Individual reports are in: $OUTPUT_DIR"
echo "Compressed archive created: system_report_$TIMESTAMP.tar.gz"
echo "Note: Some commands may require root privileges for full information"
