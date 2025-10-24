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
currentDate=`date +"%Y-%m-%d %H:%M"`

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_POD_`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_POD_*.log"

# delete the content of file
rm -f $OLD_FILES

# --- Check node cordon status ONCE ---
KPI5="Node_In_Cordon_State"
Cnt5=$(kubectl get nodes --no-headers | grep -i 'SchedulingDisabled' | awk '{print $1}' | wc -l)
value5=$(kubectl get nodes --no-headers | grep -i 'SchedulingDisabled' | awk '{print $1}' | wc -l)
kpidata5=$(kubectl get nodes --no-headers | grep -i 'SchedulingDisabled' | awk '{print $1}' | paste -sd-)

# Log Node cordon status only once
echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI5\",\"value\":\"$value5\",\"cnt\":\"$Cnt5\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"Nodes $kpidata5 are in cordon state. Check node conditions.\"}" >> $LOG_FILE

#List of define namespace
k8sNameSpaceList=("jio-mob-ebdm-platform" "jio-mob-ebdm-services" "jio-mob-ebdm-workers" "jio-fttx-ebdm-platform" "jio-fttx-ebdm-services" "jio-fttx-ebdm-workers")

for k8sNS in "${k8sNameSpaceList[@]}"
do

#get of count of pods started within 1 hours


KPI1="PODS_START_IN_ONE_HOUR"
Cnt1=`kubectl get pods -n $k8sNS --sort-by=.metadata.creationTimestamp | awk 'match($5,/^[0-1]h|^[0-9]m|^[0-9][0-9]m|^[0-9]s|^[0-9][0-9]s/) {print $0}'  |wc  -l`
value1=`kubectl get pods -n $k8sNS --sort-by=.metadata.creationTimestamp | awk 'match($5,/^[0-1]h|^[0-9]m|^[0-9][0-9]m|^[0-9]s|^[0-9][0-9]s/) {print $0}' | awk -F" " '{print $1}' |sed ':a; N; $!ba; s/\n/|/g'`
kpidata1=`kubectl get pods -n $k8sNS --sort-by=.metadata.creationTimestamp | awk 'match($5,/^[0-1]h|^[0-9]m|^[0-9][0-9]m|^[0-9]s|^[0-9][0-9]s/) {print $0}' |awk {'print $1'}| paste -sd-`

#get count of pod are not in running status

KPI2='PODS_NOT_RUNNING'
Cnt2=`kubectl get pods -n $k8sNS --field-selector=status.phase!=Running --sort-by=.metadata.creationTimestamp --no-headers |wc  -l`
value2=`kubectl get pods -n $k8sNS --field-selector=status.phase!=Running --sort-by=.metadata.creationTimestamp --no-headers | awk -F" " '{print $1}' |sed ':a; N; $!ba; s/\n/|/g'`
kpidata2=`kubectl get pods -n $k8sNS --field-selector=status.phase!=Running --sort-by=.metadata.creationTimestamp --no-headers|awk {'print $1'} | paste -sd-`

KPI3="PODS_RESTART_MUTIPLE_TIME"
Cnt3=`kubectl get pods -n $k8sNS --sort-by=.metadata.creationTimestamp | awk 'match($4,/^[3-9]|^[0-9][0-9]/) {print $0}' | wc -l`
value3=`kubectl get pods -n $k8sNS --sort-by=.metadata.creationTimestamp | awk 'match($4,/^[3-9]|^[0-9][0-9]/) {print $0}' | awk -F" " '{print $1}' |sed ':a; N; $!ba; s/\n/|/g'`
kpidata3=`kubectl get pods -n $k8sNS --sort-by=.metadata.creationTimestamp | awk 'match($4,/^[3-9]|^[0-9][0-9]/) {print $0}' |awk {'print $1'}| paste -sd-`

KPI4="DEPLOYMENT_CHANGE_TRIGGER"
Cnt4=`kubectl get rs -n $k8sNS --sort-by=.metadata.creationTimestamp | awk 'match($5,/^[0-4]h|^[0-9]m|^[0-9][0-9]m|^[0-9]s|^[0-9][0-9]s/) {print $0}' | wc  -l`
value4=`kubectl get rs -n $k8sNS --sort-by=.metadata.creationTimestamp | awk 'match($5,/^[0-4]h|^[0-9]m|^[0-9][0-9]m|^[0-9]s|^[0-9][0-9]s/) {print $0}' | awk -F" " '{print $1}' |sed ':a; N; $!ba; s/\n/|/g'`
kpidata4=`kubectl get rs -n $k8sNS --sort-by=.metadata.creationTimestamp | awk 'match($5,/^[0-4]h|^[0-9]m|^[0-9][0-9]m|^[0-9]s|^[0-9][0-9]s/) {print $0}' |awk {'print $1'}| paste -sd-`




echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI1\",\"value\":\"$Cnt1\",\"cnt\":\"$Cnt1\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"Pod $kpidata1 started within the last hour (Namespace: $k8sNS). Check deployment rollout or scaling events.\"}" >> $LOG_FILE

echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI2\",\"value\":\"$Cnt2\",\"cnt\":\"$Cnt2\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"Pod $kpidata2 is not in Running state (Namespace: $k8sNS). Check pod status, events, and logs.\"}" >> $LOG_FILE

echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI3\",\"value\":\"$Cnt3\",\"cnt\":\"$Cnt3\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"Pod $kpidata3 restarted multiple times (Namespace: $k8sNS). Check pod events, resource limits, and recent logs.\"}" >> $LOG_FILE

echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI4\",\"value\":\"$Cnt4\",\"cnt\":\"$Cnt4\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"Deployment change detected in Service: $kpidata4 and Namespace: $k8sNS. Check deployment history and Verify.\"}" >> $LOG_FILE



done
cat $LOG_FILE


