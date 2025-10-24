#!/bin/bash

# Load variables from ip.txt
source /app/NGO/NGO_ALERT_SCRIPTS/config/ip.txt

# Get IP
if [[ -n "$HARDCODED_IP" ]]; then
    IP="$HARDCODED_IP"
else
    IP=$(eval "$DYNAMIC_IP_CMD")
fi

# Get hostname
if [[ -n "$HARDCODED_HOSTNAME" ]]; then
    HOST="$HARDCODED_HOSTNAME"
else
    HOST=$(eval "$DYNAMIC_HOSTNAME_CMD")
fi
currentDate=$(date +"%Y-%m-%d %H:%M")

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_url_monitor_alert_$(date +"%Y%m%d%H%M").log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_url_monitor_alert_*.log"

# Delete old log files
rm -f $OLD_FILES

PROP_FILE="/app/NGO/NGO_ALERT_SCRIPTS/url_monitoring.properties"

trim() {
    echo "$*" | xargs
}

# Read the property file line by line
while IFS= read -r line; do
    line=$(trim "$line")
    
    # Skip empty lines or lines starting with #
    if [[ -z "$line" || "$line" =~ ^# ]]; then
        continue
    fi

    url=$(echo "$line" | awk '{print $1}')
    port=$(echo "$line" | awk '{print $2}')

    # Check connectivity using nc (netcat)
    nc -z -w5 "$url" "$port" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        failcnt=0
    else
        failcnt=1
    fi

    # NGO JSON format
    echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"URL Monitoring: ebdm2gslb.jio.com\",\"value\":\"$failcnt\",\"cnt\":\"$failcnt\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"URL ebdm2gslb.jio.com not reachable from $url on port $port. Investigate connectivity.\"}" >> "$LOG_FILE"

done < "$PROP_FILE"

