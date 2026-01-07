#!/bin/bash
# ==============================================
# Author: Shubham Patel
# Purpose: Check multiple server/port connectivity using telnet
# Features:
#   - Logs results in logs and CSV
#   - Automatically adjusts concurrency:
#       3 parallel checks (<100 targets)
#       5 parallel checks (100-500 targets)
#       10 parallel checks (>500 targets)
#   - Fully portable 
# ==============================================

INPUT_FILE="${1:-serverlist.txt}"
OUTPUT_CONNECTED="Telnet_Connected.txt"
OUTPUT_FAILED="Telnet_Failed.txt"
OUTPUT_CSV="Telnet_Results.csv"

# Check if input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found!"
    echo "Usage: $0 [serverlist.txt]"
    exit 1
fi

# Count effective server lines (ignore empty lines/comments)
SERVER_COUNT=$(grep -E '^[[:space:]]*[^#[:space:]]' "$INPUT_FILE" | wc -l)

# Exit if file is empty (no servers to check)
if (( SERVER_COUNT == 0 )); then
    echo "❌ Error: No valid server entries found in '$INPUT_FILE'!"
    exit 1
fi

# Decide concurrency based on server count
if (( SERVER_COUNT < 100 )); then
    MAX_JOBS=3
elif (( SERVER_COUNT <= 500 )); then
    MAX_JOBS=5
else
    MAX_JOBS=10
fi

echo "➡️ Total targets: $SERVER_COUNT | Concurrency: $MAX_JOBS"

# Clear old results
> "$OUTPUT_CONNECTED"
> "$OUTPUT_FAILED"
echo "Timestamp,IP,Port,Status" > "$OUTPUT_CSV"

# Function to log results
log_result() {
    local ip="$1"
    local port="$2"
    local status="$3"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    if grep -Eqi "Connected|Escape character" "$tmp"; then
        echo "$timestamp - $ip $port ......Connected" | tee -a "$OUTPUT_CONNECTED"
    else
        echo "$timestamp - $ip $port ......Failed" | tee -a "$OUTPUT_FAILED"
    fi

    echo "$timestamp,$ip,$port,$status" >> "$OUTPUT_CSV"
}

# Function to test connectivity using telnet (background -> sleep -> kill)
test_connectivity() {
    local ip="$1"
    local port="$2"
    local tmp
    tmp=$(mktemp)

    # Run telnet in background, redirect output, auto-kill after 1s, suppress "Terminated"
    ( telnet "$ip" "$port" < /dev/null >"$tmp" 2>&1 & pid=$!; 
      sleep 1; kill -9 $pid 2>/dev/null ) 2>/dev/null

    # Parse telnet output
    if grep -qi "Connected" "$tmp"; then
        log_result "$ip" "$port" "Connected"
    else
        log_result "$ip" "$port" "Failed"
    fi

    rm -f "$tmp"
}

# Run in parallel with portable concurrency control
while read -r ip port; do
    [[ -z "$ip" || "$ip" =~ ^# ]] && continue

    test_connectivity "$ip" "$port" &

    # Portable concurrency throttle
    while (( $(jobs -rp | wc -l) >= MAX_JOBS )); do
        sleep 0.2
    done
done < "$INPUT_FILE"

wait   # wait for all background jobs to finish

echo "✅ Connectivity check completed. Results saved in:"
echo "   - $OUTPUT_CONNECTED"
echo "   - $OUTPUT_FAILED"
echo "   - $OUTPUT_CSV (Excel/CSV format)"
