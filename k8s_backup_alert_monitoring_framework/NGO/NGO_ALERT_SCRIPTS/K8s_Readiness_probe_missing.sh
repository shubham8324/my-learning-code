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

LOG_DIR="/app/NGO/Logs"
LOG_FILE="$LOG_DIR/NGO_PROBE_CHECK_FAILURE_LOG_$(date +"%Y%m%d%H%M").log"
OLD_FILES="$LOG_DIR/NGO_PROBE_CHECK_FAILURE_LOG_*.log"

# Clean up old logs
rm -f $OLD_FILES

KPI_NAME="K8s Readiness probe missing"

total_count=0
kpivalue_all=""

for ns in $(kubectl get ns --no-headers | grep ebdm | awk '{print $1}'); do
  for deploy in $(kubectl get deploy -n "$ns" -o jsonpath='{.items[*].metadata.name}'); do
    json=$(kubectl get deploy "$deploy" -n "$ns" -o json)
    readiness=$(echo "$json" | jq '.spec.template.spec.containers[].readinessProbe')

    if [[ "$readiness" == "null" ]]; then
      total_count=$((total_count + 1))
      # Append each failed probe info, separated by "-"
      kpivalue_all+="Namespace-$ns-deployment-$deploy-"
    fi
  done
done

# Write only one JSON line to log file with total count and concatenated kpivalue1

echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI_NAME\",\"value\":\"$total_count\",\"cnt\":\"$total_count\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"Pod $kpivalue_all is missing a readiness probe. Check deployment spec to confirm configuration.\"}" > "$LOG_FILE"


