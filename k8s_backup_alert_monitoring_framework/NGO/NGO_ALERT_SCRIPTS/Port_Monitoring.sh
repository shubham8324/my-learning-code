#!/bin/bash

HOST=$(hostname)
IP=$(hostname -I | awk '{print $1}')

currentDate=$(date +"%Y-%m-%d %H:%M")

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_port_monitor_alert_$(date +"%Y%m%d%H%M").log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_port_monitor_alert_*.log"

# Delete old log files
rm -f $OLD_FILES

PROP_FILE="/app/NGO/NGO_ALERT_SCRIPTS/port_monitor.properties"

trim() {
    echo "$*" | xargs
}

# Read the property file line by line
while IFS= read -r category; do
    category=$(trim "$category")
    # Skip empty lines or lines starting with #
    if [[ -z "$category" || "$category" =~ ^# ]]; then
        continue
    fi
    website=$(echo "$category" | cut -d"|" -f1)
    ip_address=$(echo "$category" | cut -d"|" -f2)
    team_name=$(echo "$category" | cut -d"|" -f3)
    port=$(echo "$category" | cut -d"|" -f4)
    failcnt=$(bash /app/NGO/NGO_ALERT_SCRIPTS/nettest.sh "$ip_address" "$port" | grep "FAIL" | wc -l)
    # NGO JSON format


echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"Port Monitoring Alert\",\"value\":\"$failcnt\",\"cnt\":\"$failcnt\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"Port $port on host $website (IP: $ip_address) is unreachable. Team: $team_name. Investigate service availability.\"}" >> "$LOG_FILE"

done < "$PROP_FILE"







