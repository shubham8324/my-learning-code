#!/bin/bash

# Set the date and log info
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
HNAME=$(hostname)
CURRENT_IP=$(hostname -I | awk '{print $1}')
KPI_NAME="POD_IMAGE_DIFF"
APP_SUB_NAME="K8S_MONITOR"

BASE_DIR="/app/NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts"
SRC_FILE="$BASE_DIR/Image_version_backup/$DATE/image_info.txt"
COMPARE_DIR="$BASE_DIR/image_compare"
OUTPUT_FILE="$COMPARE_DIR/image_compare_output.txt"

LOG_DIR="/app/NGO/Logs"
LOG_FILE="$LOG_DIR/NGO_CUSTOM_UTIL_K8S_POD_IMAGE_DIFF$(date +"%Y%m%d%H%M").log"
OLD_FILES="$LOG_DIR/NGO_CUSTOM_UTIL_K8S_POD_IMAGE_DIFF*.log"

# Delete old logs
rm -f $OLD_FILES

# List of IP folders
IP_LIST=("Prod1" "Prod2" "DR1" "DR2")

# Track missing files
MISSING_FILES=()

echo "Detected current IP: $CURRENT_IP"
echo "Using date: $DATE"
echo "Fetching image_info.txt from all servers..."
echo ""

# Step 1: Fetch or copy image_info.txt for all IPs
for IP_ADDR in "${IP_LIST[@]}"; do
    TARGET_DIR="$COMPARE_DIR/$IP_ADDR"
    mkdir -p "$TARGET_DIR"

    if [[ "$CURRENT_IP" == "$IP_ADDR" ]]; then
        echo "[$IP_ADDR] - Local server. Copying file."
        if [[ -f "$SRC_FILE" ]]; then
            cp "$SRC_FILE" "$TARGET_DIR/image_info.txt"
        else
            echo "[$IP_ADDR] - Local image_info.txt file not found!"
            MISSING_FILES+=("$IP_ADDR")
        fi
    else
        echo "[$IP_ADDR] - Remote server. Fetching file via SSH."
        ssh username@$IP_ADDR cat "$BASE_DIR/Image_version_backup/$DATE/image_info.txt" > "$TARGET_DIR/image_info.txt"
        if [[ $? -ne 0 || ! -s "$TARGET_DIR/image_info.txt" ]]; then
            echo "[$IP_ADDR] - Remote image_info.txt file not found or empty!"
            MISSING_FILES+=("$IP_ADDR")
        fi
    fi
done

echo ""
echo "All files retrieved. Starting comparison..."
echo ""

CURRENT_FILE="$COMPARE_DIR/$CURRENT_IP/image_info.txt"

# Clear the output file before writing
> "$OUTPUT_FILE"

for IP_ADDR in "${IP_LIST[@]}"; do
    if [[ "$IP_ADDR" == "$CURRENT_IP" ]]; then
        continue
    fi

    COMPARE_FILE="$COMPARE_DIR/$IP_ADDR/image_info.txt"

    # Skip comparison if file was missing
    if [[ ! -f "$COMPARE_FILE" ]]; then
        continue
    fi

    echo "Comparing with $IP_ADDR..."

    # Append mismatches to output file
    awk -F'|' -v ip="$IP_ADDR" '
        NR==FNR {
            ns = $1
            svc = $2
            img = $3

            svc_prefix = svc
            if (svc ~ /\*$/) {
                sub(/\*$/, "", svc_prefix)
            } else {
                if (match(svc, /^(.*-)[^-]+$/, arr)) {
                    svc_prefix = arr[1]
                }
            }

            key = ns "|" svc_prefix "|" img
            local_lines[key] = 1
            next
        }
        {
            ns = $1
            svc = $2
            img = $3

            matched = 0
            for (k in local_lines) {
                split(k, parts, "|")
                ns_local = parts[1]
                svc_prefix_local = parts[2]
                img_local = parts[3]

                if (ns == ns_local && img == img_local && index(svc, svc_prefix_local) == 1) {
                    matched = 1
                    break
                }
            }

            if (!matched) {
                print "[Mismatch in " ip "] " $0
            }
        }
    ' "$CURRENT_FILE" "$COMPARE_FILE" >> "$OUTPUT_FILE"

    echo ""
done

echo "Comparison complete."

# Count mismatches
CNT=$(wc -l < "$OUTPUT_FILE")

if [[ "$CNT" -eq 0 ]]; then
    echo "No mismatches found."
    CNT=0
fi

# Extract info from mismatch lines
mapfile -t lines < "$OUTPUT_FILE"

parse_mismatch_line() {
    local line="$1"
    local ip=""; local ns=""; local svc=""; local deploy=""

    if [[ "$line" =~ \[Mismatch\ in\ ([^\]]+)\]\ ([^|]+)\|([^|]+) ]]; then
        ip="${BASH_REMATCH[1]}"
        ns="${BASH_REMATCH[2]}"
        svc="${BASH_REMATCH[3]}"

        if [[ "$svc" =~ ^(.*)-[^-]+$ ]]; then
            deploy="${BASH_REMATCH[1]}"
        else
            deploy="$svc"
        fi
    fi

    echo "$ip|$ns|$deploy"
}

# Build kpivalue dynamically for all mismatches
kpivalue="Image_Mismatch_Details:"

for line in "${lines[@]}"; do
    IFS="|" read -r ip ns deploy <<< "$(parse_mismatch_line "$line")"
    
    # Remove spaces for JSON-safe strings
    ns_json=$(echo "$ns" | tr -d ' ')
    deploy_json=$(echo "$deploy" | tr -d ' ')
    
    kpivalue+="  IP: $ip, Deployment: $deploy_json and Namespace: $ns_json;"
done

# Build kpivalue2 dynamically for all mismatches
kpivalue2="Image_Mismatch_Details:"

# Append missing file info if any
if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
    for ip in "${MISSING_FILES[@]}"; do
        kpivalue2+=" |image file not present in IP: $ip check the server"
    done
fi

# Write JSON log
echo "{\"ts\":\"$TIMESTAMP\",\"ip\":\"$CURRENT_IP\",\"hname\":\"$HNAME\",\"kpi\":\"$KPI_NAME\",\"value\":\"$CNT\",\"cnt\":\"$CNT\",\"app_sub_name\":\"$APP_SUB_NAME\",\"kpivalue1\":\"Pod image mismatch detected in $kpivalue Compare running pod image in Prod/DR. $kpivalue2\"}" > "$LOG_FILE"

echo "Log written to $LOG_FILE"
echo "Mismatch count: $CNT"

