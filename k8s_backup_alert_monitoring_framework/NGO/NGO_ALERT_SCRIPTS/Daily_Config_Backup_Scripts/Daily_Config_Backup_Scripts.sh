#!/bin/bash
# K8s Daily Backup Script

# Base Path
BASE_PATH="/app/NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts"
DATE=$(date +%Y-%m-%d)

# Retention (delete backups older than 30 days)
find "$BASE_PATH" -type d -mtime +30 -exec rm -rf {} +

# Get namespaces with 'ebdm'
NAMESPACES=$(kubectl get ns --no-headers | awk '{print $1}' | grep ebdm)

if [ -z "$NAMESPACES" ]; then
  echo "No namespaces found containing 'ebdm'. Exiting..."
  exit 1
fi

echo "Namespaces: $NAMESPACES"

### POD BACKUP ###
POD_PATH="$BASE_PATH/pod_backup/$DATE"
mkdir -p "$POD_PATH"
> "$POD_PATH/All_Pods_backup.csv"   # clear file before writing
for ns in $NAMESPACES; do
  kubectl get pods -n "$ns" -o wide >> "$POD_PATH/All_Pods_backup.csv"
done

### DEPLOYMENT BACKUP ###
DEPLOY_CSV_PATH="$BASE_PATH/deployment_backup/All_Deployment_backup/$DATE"
DEPLOY_YAML_PATH="$BASE_PATH/deployment_backup/All_Deployment_yaml_backup/$DATE"
mkdir -p "$DEPLOY_CSV_PATH" "$DEPLOY_YAML_PATH"

DEPLOY_CSV_FILE="$DEPLOY_CSV_PATH/All_Deployment_backup.csv"

# Print header
echo "namespace,deploymentname                                 READY   UP-TO-DATE   AVAILABLE   AGE" > "$DEPLOY_CSV_FILE"

for ns in $NAMESPACES; do
  kubectl get deploy -n "$ns" | tail -n +2 | while read -r line; do
    deployname=$(echo "$line" | awk '{print $1}')
    rest=$(echo "$line" | cut -d' ' -f2-)
    printf "%s,%s%s\n" "$ns" "$deployname" "$rest" >> "$DEPLOY_CSV_FILE"
  done

  # Save YAMLs
  NS_PATH="$DEPLOY_YAML_PATH/$ns"
  mkdir -p "$NS_PATH"
  for deploy in $(kubectl get deploy -n "$ns" -o jsonpath='{.items[*].metadata.name}'); do
    kubectl get deploy "$deploy" -n "$ns" -o yaml > "$NS_PATH/${deploy}.yaml"
  done
done

### CONFIGMAP BACKUP ###
CM_JSON_PATH="$BASE_PATH/config_prop_backup/$DATE"
CM_PROP_PATH="$BASE_PATH/config_prop_backup/all_properties/$DATE"
mkdir -p "$CM_JSON_PATH" "$CM_PROP_PATH"

for ns in $NAMESPACES; do
  NS_JSON_PATH="$CM_JSON_PATH/$ns/all_cm_json"
  NS_PROP_PATH="$CM_PROP_PATH/$ns"
  mkdir -p "$NS_JSON_PATH" "$NS_PROP_PATH"

  for cm in $(kubectl get cm -n "$ns" -o jsonpath='{.items[*].metadata.name}'); do
    # Full JSON
    kubectl get cm "$cm" -n "$ns" -o json > "$NS_JSON_PATH/${cm}.props.json"

    # Extract data fields into .property file (if present)
    kubectl get cm "$cm" -n "$ns" -o jsonpath='{.data}' \
      | jq -r 'to_entries[] | "\(.key)=\(.value)"' > "$NS_PROP_PATH/${cm}.property" 2>/dev/null
  done
done

### IMAGE VERSION BACKUP (single unified, no duplicates) ###
IMG_PATH="$BASE_PATH/Image_version_backup/$DATE"
mkdir -p "$IMG_PATH"
OUTPUT_FILE="$IMG_PATH/image_info.txt"
> "$OUTPUT_FILE"

declare -A seen_images

for ns in $NAMESPACES; do
  deployments=$(kubectl get deploy -n "$ns" -o jsonpath='{.items[*].metadata.name}')
  for deploy in $deployments; do
    images=$(kubectl get deploy "$deploy" -n "$ns" -o jsonpath='{.spec.template.spec.containers[*].image}' | tr ' ' '\n')

    for image in $images; do
      line="${ns}|${deploy}|${image}"
      if [[ -z "${seen_images[$line]}" ]]; then
        echo "$line" >> "$OUTPUT_FILE"
        seen_images[$line]=1
      fi
    done
  done
done

### SERVICE BACKUP ###
SVC_PATH="$BASE_PATH/SVC_backup/$DATE"
mkdir -p "$SVC_PATH"
for ns in $NAMESPACES; do
  NS_SVC_PATH="$SVC_PATH/$ns"
  mkdir -p "$NS_SVC_PATH"
  for svc in $(kubectl get svc -n "$ns" -o jsonpath='{.items[*].metadata.name}'); do
    kubectl get svc "$svc" -n "$ns" -o yaml > "$NS_SVC_PATH/${svc}.yaml"
  done
done

echo "✅ Backup completed successfully at $DATE"


