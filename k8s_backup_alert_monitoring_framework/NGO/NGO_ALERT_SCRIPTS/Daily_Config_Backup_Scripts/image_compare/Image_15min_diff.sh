#!/bin/bash
# ------------------------------------------------------------------
# Script Name : pod_image_diff.sh
# Description : Compares Kubernetes pod images from the last 15 minutes.
#               Logs JSON alerts when differences are found.
#               Combines image differences per deployment into one JSON line.
# ------------------------------------------------------------------

set -euo pipefail

# ------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
KPI_NAME="POD_IMAGE_DIFF"
APP_SUB_NAME="K8S_MONITOR"

SCRIPT_DIR="/app/NGO/NGO_ALERT_SCRIPTS"
BACKUP_DIR="$SCRIPT_DIR/Daily_Config_Backup_Scripts/image_compare"

LOG_DIR="/app/NGO/Logs"
LOG_FILE="$LOG_DIR/NGO_CUSTOM_UTIL_K8S_POD_IMAGE_DIFF_$(date +"%Y%m%d%H%M").log"
OLD_FILES="$LOG_DIR/NGO_CUSTOM_UTIL_K8S_POD_IMAGE_DIFF_*.log"

# ------------------------------------------------------------------
# Prepare Log Directory
# ------------------------------------------------------------------
mkdir -p "$LOG_DIR"
rm -f $OLD_FILES 2>/dev/null || true

# ------------------------------------------------------------------
# Load variables from ip.txt
# ------------------------------------------------------------------
source /app/NGO/NGO_ALERT_SCRIPTS/config/ip.txt

# Get IP address
if [[ -n "${HARDCODED_IP:-}" ]]; then
    IP="$HARDCODED_IP"
else
    IP=$(eval "$DYNAMIC_IP_CMD")
fi

# Get hostname
if [[ -n "${HARDCODED_HOSTNAME:-}" ]]; then
    HOST="$HARDCODED_HOSTNAME"
else
    HOST=$(eval "$DYNAMIC_HOSTNAME_CMD")
fi

# ------------------------------------------------------------------
# Prepare Working Directory
# ------------------------------------------------------------------
cd "$BACKUP_DIR" || { echo "Failed to cd to $BACKUP_DIR"; exit 1; }

# Rotate snapshot files: current becomes old
mv -f Image_now.txt Image_15min.txt 2>/dev/null || true

# Collect current images in namespaces matching "ebdm"
kubectl get ns --no-headers | awk '/ebdm/ {print $1}' | while read -r ns; do
    kubectl get deploy -n "$ns" -o json | \
    jq -r '.items[] | "\(.metadata.namespace)|\(.metadata.name)|\(.spec.template.spec.containers[].image)"'
done > Image_now.txt

# ------------------------------------------------------------------
# If no previous snapshot, exit silently
# ------------------------------------------------------------------
if [[ ! -s Image_15min.txt ]]; then
    exit 0
fi

# ------------------------------------------------------------------
# Prepare temp files for old and new image mappings
# ------------------------------------------------------------------
old_map_file=$(mktemp)
new_map_file=$(mktemp)

# Format: key (ns|deploy) = images separated by ;
# We'll accumulate lines here

# Get diff output, ignore diff exit code
diff_output=$(diff Image_15min.txt Image_now.txt || true)

# Process diff output line by line
while IFS= read -r line; do
    if [[ "$line" =~ ^\<\ (.*) ]]; then
        old_line="${BASH_REMATCH[1]}"
        ns=$(echo "$old_line" | cut -d'|' -f1 | xargs)
        deploy=$(echo "$old_line" | cut -d'|' -f2 | xargs)
        image=$(echo "$old_line" | cut -d'|' -f3- | xargs)
        key="${ns}|${deploy}"

        # Append image to old_map_file for the key
        # Check if key already exists
        if grep -q "^$key=" "$old_map_file"; then
            # Append new image with ;
            old_images=$(grep "^$key=" "$old_map_file" | cut -d'=' -f2)
            new_images="${old_images};${image}"
            # Update line
            sed -i "s|^$key=.*|$key=$new_images|" "$old_map_file"
        else
            echo "$key=$image" >> "$old_map_file"
        fi

    elif [[ "$line" =~ ^\>\ (.*) ]]; then
        new_line="${BASH_REMATCH[1]}"
        ns=$(echo "$new_line" | cut -d'|' -f1 | xargs)
        deploy=$(echo "$new_line" | cut -d'|' -f2 | xargs)
        image=$(echo "$new_line" | cut -d'|' -f3- | xargs)
        key="${ns}|${deploy}"

        # Append image to new_map_file for the key
        if grep -q "^$key=" "$new_map_file"; then
            new_images=$(grep "^$key=" "$new_map_file" | cut -d'=' -f2)
            new_images="${new_images};${image}"
            sed -i "s|^$key=.*|$key=$new_images|" "$new_map_file"
        else
            echo "$key=$image" >> "$new_map_file"
        fi
    fi
done <<< "$diff_output"

# ------------------------------------------------------------------
# If no differences found, exit silently
# ------------------------------------------------------------------
if [[ ! -s "$new_map_file" ]]; then
    # Clean up temp files
    rm -f "$old_map_file" "$new_map_file"
    exit 0
fi

# Count total differing deployments
DIFF_COUNT=$(wc -l < "$new_map_file" | tr -d ' ')

# ------------------------------------------------------------------
# Write JSON log lines for each deployment with image differences
# ------------------------------------------------------------------
# Prepare combined kpivalue1 string
kpivalue_all=""

while IFS= read -r line; do
    key=$(echo "$line" | cut -d'=' -f1)
    IMAGE_NOW=$(echo "$line" | cut -d'=' -f2-)

    IMAGE_BEFORE=$(grep "^$key=" "$old_map_file" | cut -d'=' -f2- || echo "N/A")

    ns="${key%%|*}"
    deploy="${key#*|}"

    # Build partial string for this deployment difference
    partial="Namespace:${ns}, Service:${deploy}, Image_15min_Before:${IMAGE_BEFORE}, Image_Now:${IMAGE_NOW}"

    # Append with semicolon separator if not first
    if [[ -z "$kpivalue_all" ]]; then
        kpivalue_all="$partial"
    else
        kpivalue_all="${kpivalue_all}; ${partial}"
    fi
done < "$new_map_file"

# Print single JSON line combining all deployment diffs
printf '{"ts":"%s","ip":"%s","hname":"%s","kpi":"%s","value":"%d","cnt":"%d","app_sub_name":"%s","kpivalue1":"Image_Mismatch_Found: IP:%s, %s"}\n' \
    "$TIMESTAMP" "$IP" "$HOST" "$KPI_NAME" "$DIFF_COUNT" "$DIFF_COUNT" "$APP_SUB_NAME" "$IP" "$kpivalue_all" >> "$LOG_FILE"


# Cleanup temp files
rm -f "$old_map_file" "$new_map_file"

exit 0


