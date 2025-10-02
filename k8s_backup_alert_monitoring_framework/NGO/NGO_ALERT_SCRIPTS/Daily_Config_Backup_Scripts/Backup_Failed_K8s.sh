#!/bin/bash

### ✅ VERIFY BACKUP COMPLETION AND LOG IF FAILED ###

TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
LOG_TIME=$(date +"%Y%m%d%H%M")

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_backup_failure_log${LOG_TIME}.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_backup_failure_log*.log"

# Optionally clean up old log files
# Uncomment the line below if you really want to delete old logs
# rm -f $OLD_FILES

IP=$(hostname -I | awk '{print $1}')
HNAME=$(hostname)
KPI_NAME="EBDM_Backup_Failed_K8s"
APP_SUB_NAME="K8S_MONITOR"

FAILED_BACKUPS=()

# Define expected backup paths
declare -A BACKUP_PATHS=(
  ["pod_backup"]="/app/NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts/pod_backup/${TODAY}"
  ["deployment_backup"]="/app/NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts/deployment_backup/All_Deployment_backup/${TODAY}"
  ["config_prop_backup"]="/app/NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts/config_prop_backup/${TODAY}"
  ["Image_version_backup"]="/app/NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts/Image_version_backup/${TODAY}"
  ["SVC_backup"]="/app/NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts/SVC_backup/${TODAY}"
)

# Check each expected backup directory
for BACKUP_NAME in "${!BACKUP_PATHS[@]}"; do
  DIR="${BACKUP_PATHS[$BACKUP_NAME]}"
  if [ ! -d "$DIR" ]; then
    FAILED_BACKUPS+=("$BACKUP_NAME")
  fi
done

if [ ${#FAILED_BACKUPS[@]} -gt 0 ]; then
  KPI_VALUE1="$KPI_NAME - $(IFS=,; echo "${FAILED_BACKUPS[*]}")"
  CNT=${#FAILED_BACKUPS[@]}

  JSON_ENTRY=$(cat <<EOF
{"ts":"$TIMESTAMP","ip":"$IP","hname":"$HNAME","kpi":"$KPI_NAME","value":"$CNT","cnt":"$CNT","app_sub_name":"$APP_SUB_NAME","kpivalue1":"Backup failure detected for Kubernetes $KPI_VALUE1. Check backup job logs and last successful backup timestamp."}

EOF
)
  echo "$JSON_ENTRY" >> "$LOG_FILE"
  echo "❌ Backup verification failed. Logged to $LOG_FILE"
else
  echo "✅ All backup folders verified for today: $TODAY"
fi

