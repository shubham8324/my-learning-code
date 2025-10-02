#!/bin/sh

# Get hostname and primary IP address
HOST=$(hostname)
IP=$(hostname -I | awk '{print $1}')
currentDate=$(date +"%Y-%m-%d %H:%M")

LOG_DIR="/app/NGO/Logs"
LOG_FILE="$LOG_DIR/NGO_CUSTOM_UTIL_K8S_Deployment_HPA_Missing_$(date +"%Y%m%d%H%M").log"
OLD_FILES="$LOG_DIR/NGO_CUSTOM_UTIL_K8S_Deployment_HPA_Missing_*.log"

# Delete old log files (be careful!)
rm -f "$OLD_FILES"

# Source bash profile to load environment variables
. "$HOME/.bash_profile"

# Variables
excl='!'
WORK_DIR="/app/Prometheus/Deployment_HPA_Missing"
CONFIG_DIR="/app/Prometheus/config"
CONFIG_FILE="$CONFIG_DIR/prometheus_servers_config.conf"
METRICS_NAME="Deployment_HPA_Missing"

# Prepare working files
cd "$WORK_DIR" || exit 1
: > pod_log_curl.txt
: > pod_thread.log

# Loop over relevant lines in config file
grep -w "$METRICS_NAME" "$CONFIG_FILE" | awk '{print $2 "|" $3 "|" $4}' | while IFS='|' read -r CLUSTER_NAME URL_IP CLUSTER_IP; do

    C_URL="http://$URL_IP/api/v1/query?query=count%20by%20(namespace%2C%20deployment)%20(kube_deployment_labels%7Bnamespace%3D~%22.*-ebdm-.*%22%7D)%20unless%20count%20by%20(namespace%2C%20target_name)%20(kube_hpa_spec_target_name%7Bnamespace%3D~%22.*-ebdm-.*%22%7D)"

    # Fetch data from Prometheus using curl and jq
    curl -u admin:'Prometheu$@123' "$C_URL" | \
      jq -r '.data.result[] | "\(.metric.namespace)|\(.metric.deployment)|\(.value[1])"' >> pod_log_curl.txt

    file_count=$(wc -l < pod_log_curl.txt)
    if [ "$file_count" -gt 0 ]; then
        while IFS='|' read -r namespace deployment count; do

            echo "$CLUSTER_NAME $CLUSTER_IP $namespace $deployment $count" >> pod_thread.log

            ALT_TEXT="PROD ALERT: $METRICS_NAME, CLUSTER_NAME: $CLUSTER_NAME, NAMESPACE: $namespace, deployment: $deployment, COUNT: $count"
            #echo "$ALT_TEXT"

            # Append JSON log entry
                echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$METRICS_NAME\",\"value\":\"$count\",\"cnt\":\"$count\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"Deployment $deployment and Namespace: $namespace has no HPA configured. Check scaling requirements and HPA status.\"}" >> "$LOG_FILE"    
    done < pod_log_curl.txt
    fi

    # Clear pod_log_curl.txt for next iteration
    : > pod_log_curl.txt

done

# Optional: print log file content and a message
echo "Log file content:"
cat "$LOG_FILE"
echo "Check the script completed."

