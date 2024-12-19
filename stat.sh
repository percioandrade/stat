#!/usr/bin/env bash
# =============================================================================
# Name: stat.sh
# Description: Monitors and displays active network connections by port, with
#             color-coded output based on connection volume:
#             - Green: < 20 connections
#             - Orange: 20-50 connections
#             - Red: > 50 connections
#
# Author: Percio Andrade [ percio@zendev.com.br - https://zendev.com.br ]
# Version: 1.1
#
# Requirements:
#   - Must be run as root/superuser
#   - Required commands: ss, awk, sort, uniq
#
# Usage:
#   sudo ./stat.sh [OPTIONS]
#
# Options:
#   -n NUMBER    Show top N ports (default: 10)
#   -i INTERVAL  Refresh interval in seconds (default: no refresh)
#   -h          Show this help message
#
# Output:
#   Displays ports sorted by number of active connections
#   Format: Port - Total Connections (color coded)
# =============================================================================

set -euo pipefail

# Default values
TOP_N=10
INTERVAL=0

# ANSI color codes
readonly GREEN='\e[32m'
readonly ORANGE='\e[33m'
readonly RED='\e[31m'
readonly RESET='\e[0m'

usage() {
    grep '^#' "$0" | grep -v '#!/usr/bin/env' | sed 's/^#//'
    exit 1
}

# Parse command line options
while getopts "n:i:h" opt; do
    case $opt in
        n) TOP_N="$OPTARG"
           [[ "$TOP_N" =~ ^[0-9]+$ ]] || { echo "Error: -n requires a number" >&2; exit 1; }
           ;;
        i) INTERVAL="$OPTARG"
           [[ "$INTERVAL" =~ ^[0-9]+$ ]] || { echo "Error: -i requires a number" >&2; exit 1; }
           ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root/superuser" >&2
    exit 1
fi

# Check required commands
declare -a REQUIRED_COMMANDS=("ss" "awk" "sort" "uniq")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: Required command '$cmd' is not installed." >&2
        exit 1
    fi
done

# Function to determine the color based on the number of connections
get_color() {
    local total=$1
    if [[ "$total" -lt 20 ]]; then
        echo -ne "$GREEN"
    elif [[ "$total" -ge 20 && "$total" -le 50 ]]; then
        echo -ne "$ORANGE"
    else
        echo -ne "$RED"
    fi
}

# Function to gather and display port statistics
display_stats() {
    local port_info
    local processed_info
    local sorted_ports

    # Clear screen if in refresh mode
    [[ $INTERVAL -gt 0 ]] && clear

    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Monitoring top $TOP_N ports by connection count"
    echo "----------------------------------------"
    echo "Port - Total Connections"
    echo "----------------------------------------"

    # Gather port statistics using ss
    if ! port_info=$(ss -tuln 2>&1); then
        echo "Error: Failed to gather network statistics" >&2
        exit 1
    fi

    if echo "$port_info" | grep -q "Protocol not supported"; then
        echo "Error: Netlink protocol is not supported on this system" >&2
        exit 1
    fi

    # Process and sort the port information
    processed_info=$(echo "$port_info" |
        awk 'NR>1 {split($5, a, ":"); print a[length(a)]}' |
        sort |
        uniq -c)

    sorted_ports=$(echo "$processed_info" | sort -rn | head -n "$TOP_N")

    # Display results
    while read -r line; do
        [[ -z "$line" ]] && continue
        local total port
        total=$(echo "$line" | awk '{print $1}')
        port=$(echo "$line" | awk '{print $2}')
        printf "%s%-5s - %d${RESET}\n" "$(get_color "$total")" "$port" "$total"
    done <<< "$sorted_ports"

    echo "----------------------------------------"
}

# Main execution loop
while true; do
    display_stats
    [[ $INTERVAL -eq 0 ]] && break
    sleep "$INTERVAL"
done