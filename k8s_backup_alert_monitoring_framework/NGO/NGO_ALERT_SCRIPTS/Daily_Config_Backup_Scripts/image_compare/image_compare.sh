#!/bin/bash

# ==========================================
# K8S Image Comparison Script (Simplified)
# ==========================================

set -u
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
KPI_NAME="POD_IMAGE_DIFF"
APP_SUB_NAME="K8S_MONITOR"

# Load IP/Host configuration
source /app/NGO/NGO_ALERT_SCRIPTS/config/ip.txt

# Determine current IP
if [[ -n "${HARDCODED_IP:-}" ]]; then
    IP="$HARDCODED_IP"
else
    IP=$(eval "$DYNAMIC_IP_CMD")
fi

# Determine hostname
if [[ -n "${HARDCODED_HOSTNAME:-}" ]]; then
    HOST="$HARDCODED_HOSTNAME"
else
    HOST=$(eval "$DYNAMIC_HOSTNAME_CMD")
fi

BASE_DIR="/app/NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts"
COMPARE_DIR="$BASE_DIR/image_compare"
LOG_DIR="/app/NGO/Logs"
LOG_FILE="$LOG_DIR/NGO_CUSTOM_UTIL_K8S_POD_IMAGE_DIFF$(date +"%Y%m%d%H%M").log"
MISSING_IMAGE_OUTPUT="$COMPARE_DIR/missing_images_across_clusters.txt"

# Define clusters
IP_LIST=("10.137.51.131" "10.137.51.140" "10.148.161.163" "10.148.160.185")
PROD_IPS=("10.137.51.131" "10.137.51.140")
DR_IPS=("10.148.161.163" "10.148.160.185")

mkdir -p "$COMPARE_DIR" "$LOG_DIR"

echo "Detected current IP: $IP"
echo "Using date: $DATE"
echo "Fetching image_info.txt from all servers..."
echo ""

MISSING_FILES=()

# ==========================================
# STEP 1: Retrieve image_info.txt from all clusters
# ==========================================
for IP_ADDR in "${IP_LIST[@]}"; do
    TARGET_DIR="$COMPARE_DIR/$IP_ADDR"
    mkdir -p "$TARGET_DIR"
    SRC_FILE="$BASE_DIR/Image_version_backup/$DATE/image_info.txt"

    if [[ "$IP" == "$IP_ADDR" ]]; then
        echo "[$IP_ADDR] Local server - copying file."
        if [[ -f "$SRC_FILE" ]]; then
            cp "$SRC_FILE" "$TARGET_DIR/image_info.txt"
        else
            echo "[$IP_ADDR] Local image_info.txt missing!"
            MISSING_FILES+=("$IP_ADDR")
        fi
    else
        echo "[$IP_ADDR] Fetching via SSH..."
        ssh -o BatchMode=yes -o ConnectTimeout=10 SIEBDMK8S@"$IP_ADDR" cat "$SRC_FILE" > "$TARGET_DIR/image_info.txt" 2>/dev/null
        if [[ $? -ne 0 || ! -s "$TARGET_DIR/image_info.txt" ]]; then
            echo "[$IP_ADDR] image_info.txt missing or empty!"
            MISSING_FILES+=("$IP_ADDR")
        fi
    fi
done

echo ""
echo "All files retrieved. Starting comparison..."
echo ""

> "$MISSING_IMAGE_OUTPUT"

# ==========================================
# STEP 2: Build map of images across clusters
# ==========================================
declare -A IMAGE_MAP

for IP_ADDR in "${IP_LIST[@]}"; do
    FILE="$COMPARE_DIR/$IP_ADDR/image_info.txt"
    [[ ! -s "$FILE" ]] && continue

    while IFS='|' read -r ns svc img; do
        [[ -z "$ns" || "$ns" == *"utility"* || "$svc" == *"utility"* || "$img" == *"utility"* ]] && continue

        svc_prefix="$svc"
        if [[ "$svc" =~ \*$ ]]; then
            svc_prefix="${svc%\*}"
        elif [[ "$svc" =~ ^(.*)-[^-]+$ ]]; then
            svc_prefix="${BASH_REMATCH[1]}"
        fi

        key="$ns|$svc_prefix|$img"
        IMAGE_MAP["$key"]+="$IP_ADDR,"
    done < "$FILE"
done

# ==========================================
# STEP 3: Detect missing and mismatched images
# ==========================================
kpivalue_not_found=""
kpivalue_mismatch=""
CNT=0

for key in "${!IMAGE_MAP[@]}"; do
    found_ips="${IMAGE_MAP[$key]}"
    IFS='|' read -r ns svc_prefix img <<< "$key"

    # Skip utility
    [[ "$ns" == *"utility"* || "$svc_prefix" == *"utility"* || "$img" == *"utility"* ]] && continue

    # Check missing in any cluster
    for IP_ADDR in "${IP_LIST[@]}"; do
        if [[ "$found_ips" != *"$IP_ADDR,"* ]]; then
            echo "Image [$img] with Service [$svc_prefix] in Namespace [$ns] is MISSING in [$IP_ADDR]" >> "$MISSING_IMAGE_OUTPUT"
            kpivalue_not_found+=" IP:$IP_ADDR, Namespace:$ns, Service:$svc_prefix, Image:$img;"
            ((CNT++))
        fi
    done
done


# ==========================================
# STEP 4 (Improved): Detect image mismatch and missing only once
# ==========================================

declare -A CLUSTER_IMAGE_MAP
declare -A IMAGE_COUNT
declare -A UNIQUE_SVCNS

# Build ns|svc_prefix -> image per IP map
for key in "${!IMAGE_MAP[@]}"; do
    IFS='|' read -r ns svc_prefix img <<< "$key"
    found_ips="${IMAGE_MAP[$key]}"
    svcns="$ns|$svc_prefix"
    UNIQUE_SVCNS["$svcns"]=1
    for ip in "${IP_LIST[@]}"; do
        if [[ "$found_ips" == *"$ip,"* ]]; then
            CLUSTER_IMAGE_MAP["$svcns|$ip"]="$img"
        fi
    done
done

> "$MISSING_IMAGE_OUTPUT"

declare -A MISSING_ENTRIES
declare -A MISMATCH_ENTRIES
CNT_NOT_FOUND=0
CNT_MISMATCH=0
# Detect missing images (use image name from other clusters if available)
for svcns in "${!UNIQUE_SVCNS[@]}"; do
    IFS='|' read -r ns svc_prefix <<< "$svcns"

    # Find an image used in any other cluster as reference
    reference_img=""
    for ip in "${IP_LIST[@]}"; do
        img="${CLUSTER_IMAGE_MAP["$svcns|$ip"]:-}"
        if [[ -n "$img" ]]; then
            reference_img="$img"
            break
        fi
    done

    # Skip if even reference not found (should not happen)
    [[ -z "$reference_img" ]] && continue

    # Now check for clusters where image missing
    for ip in "${IP_LIST[@]}"; do
        if [[ -z "${CLUSTER_IMAGE_MAP["$svcns|$ip"]:-}" ]]; then
            key="IP:$ip|NS:$ns|SVC:$svc_prefix"
            if [[ -z "${MISSING_ENTRIES[$key]:-}" ]]; then
                MISSING_ENTRIES["$key"]=1
                echo "Image_Not_Found_Details: IP:$ip, Namespace:$ns, Service:$svc_prefix, Image:$reference_img" >> "$MISSING_IMAGE_OUTPUT"
                CNT_NOT_FOUND=$((CNT_NOT_FOUND + 1))
            fi
        fi
    done
done


# Detect mismatches
for svcns in "${!UNIQUE_SVCNS[@]}"; do
    declare -A imgs_for_svcns=()
    IFS='|' read -r ns svc_prefix <<< "$svcns"

    for ip in "${IP_LIST[@]}"; do
        img="${CLUSTER_IMAGE_MAP["$svcns|$ip"]:-}"
        [[ -n "$img" ]] && imgs_for_svcns["$img"]+=1
    done

    if (( ${#imgs_for_svcns[@]} > 1 )); then
        # Identify majority image
        majority_img=""
        majority_cnt=0
        for img in "${!imgs_for_svcns[@]}"; do
            cnt=${imgs_for_svcns["$img"]}
            if (( cnt > majority_cnt )); then
                majority_cnt=$cnt
                majority_img="$img"
            fi
        done

        # Log wrong images
        for ip in "${IP_LIST[@]}"; do
            test_img="${CLUSTER_IMAGE_MAP["$svcns|$ip"]:-}"
            if [[ -n "$test_img" && "$test_img" != "$majority_img" ]]; then
                key="NS:$ns|SVC:$svc_prefix|IP:$ip"
                if [[ -z "${MISMATCH_ENTRIES[$key]:-}" ]]; then
                    MISMATCH_ENTRIES["$key"]=1
                    echo "Wrong_Image_Found: Namespace:$ns, Service:$svc_prefix, IP:$ip, Image:$test_img (Expected:$majority_img)" >> "$MISSING_IMAGE_OUTPUT"
                    CNT_MISMATCH=$((CNT_MISMATCH + 1))
                fi
            fi
        done
    fi
    unset imgs_for_svcns
done

# ==========================================
# STEP 5: Prepare final JSON log
# ==========================================
TOTAL_CNT=$((CNT_NOT_FOUND + CNT_MISMATCH))

# Prepare JSON-friendly KPI value
kpivalue_not_found_output=""
kpivalue_mismatch_output=""

if (( CNT_MISMATCH > 0 )); then
    for k in "${!MISMATCH_ENTRIES[@]}"; do
        kpivalue_mismatch_output+="$(grep 'Wrong_Image_Found' "$MISSING_IMAGE_OUTPUT" | tr '\n' ' ')"
        break
    done
fi

if (( CNT_NOT_FOUND > 0 )); then
    for k in "${!MISSING_ENTRIES[@]}"; do
        kpivalue_not_found_output+="$(grep 'Image_Not_Found_Details' "$MISSING_IMAGE_OUTPUT" | tr '\n' ' ')"
        break
    done
fi

# Reorder file: Wrong_Image_Found first, then Image_Not_Found
TMPFILE=$(mktemp)
grep '^Wrong_Image_Found' "$MISSING_IMAGE_OUTPUT" >> "$TMPFILE"
grep '^Image_Not_Found_Details' "$MISSING_IMAGE_OUTPUT" >> "$TMPFILE"
mv "$TMPFILE" "$MISSING_IMAGE_OUTPUT"

# Final log JSON
echo "{\"ts\":\"$TIMESTAMP\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI_NAME\",\"value\":\"$TOTAL_CNT\",\"cnt\":\"$TOTAL_CNT\",\"app_sub_name\":\"$APP_SUB_NAME\",\"kpivalue1\":\"${kpivalue_not_found_output:+Image_Not_Found_Details: }${kpivalue_not_found_output} ${kpivalue_mismatch_output:+Image_Mismatch_Details: }${kpivalue_mismatch_output}\"}" > "$LOG_FILE"

echo ""
echo "✅ Report written to: $MISSING_IMAGE_OUTPUT"
echo "✅ Log written to: $LOG_FILE"
echo "✅ Total Issues Found (Missing + Mismatch): $TOTAL_CNT"

