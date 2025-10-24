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

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_HPA_`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_HPA_*.log"

# delete the content of file
rm -f $OLD_FILES

#List of define namespace

OcNameSpaceList=("jio-fttx-ebdm-platform" "jio-fttx-ebdm-services" "jio-fttx-ebdm-workers")

for OcNS in "${OcNameSpaceList[@]}"
do
#get of define hpa in NameSpace

hpaList=$(kubectl get hpa -n "$OcNS" 2>/dev/null | awk '{print $1}' | grep -v NAME | xargs echo)

kpi1Cnt=0
kpi2Cnt=0
kpi3Cnt=0

KPI1="HPA_MAX_EQ_MIN_POD"
KPI2="HPA_CURRENT_EQ_MAX_POD"
KPI3="HPA_CURRENT_LESSTHEN_MIN_POD"

for hpaName in $hpaList

do

echo  $OcNS---- $hpaName hpa monitor -----------------------------


hpaData=$(kubectl get hpa "$hpaName" -n "$OcNS" -o=jsonpath='{.spec.maxReplicas},{.spec.minReplicas},{.status.currentReplicas},{.spec.targetCPUUtilizationPercentage},{.status.currentCPUUtilizationPercentage}')

echo $hpaData

IFS=, read -r maxReplicas minReplicas currentReplicas targetCPUUtilizationPercentage currentCPUUtilizationPercentage <<< "${hpaData}"

echo "maxReplicas="$maxReplicas "minReplicas="$minReplicas "currentReplicas="$currentReplicas "targetCPUUtilizationPercentage="$targetCPUUtilizationPercentage "currentCPUUtilizationPercentage="$currentCPUUtilizationPercentage

if [[ $maxReplicas = $minReplicas ]];
then

VALUE1="$OcNS:$hpaName:max($maxReplicas)=min($minReplicas)"
kpi1Cnt=$(( $kpi1Cnt + 1 ))
echo "$KPI1:$VALUE1:$kpi1Cnt"

fi

if [[ $currentReplicas = $maxReplicas ]];
then
VALUE2="$OcNS:$hpaName:cuurent($currentReplicas)=max($maxReplicas)"
kpi2Cnt=$(( $kpi2Cnt + 1 ))
echo "$KPI2:$VALUE2:$kpi2Cnt"




fi


if [[   $currentReplicas -lt $minReplicas ]];
then

VALUE3="$OcNS:$hpaName:cuurent($currentReplicas)<min($minReplicas)"
kpi3Cnt=$(( $kpi3Cnt + 1 ))
echo "$KPI3:$VALUE3:$kpi3Cnt"

fi


echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI1\",\"value\":\"$kpi1Cnt\",\"cnt\":\"$kpi1Cnt\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"HPA $hpaName (Namespace: $OcNS) has max pods equal to min pods. Check scaling policy configuration.\"}" >> $LOG_FILE

echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI2\",\"value\":\"$kpi2Cnt\",\"cnt\":\"$kpi2Cnt\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"HPA $hpaName (Namespace: $OcNS) reached maximum pod limit. Check scaling events.\"}" >> $LOG_FILE

echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI3\",\"value\":\"$kpi3Cnt\",\"cnt\":\"$kpi3Cnt\",\"app_sub_name\":\"K8S_MONITOR\",\"kpivalue1\":\"HPA $hpaName (Namespace: $OcNS) has fewer pods than the configured minimum. Check HPA configuration and recent scaling activity.\"}" >> $LOG_FILE





done
done

cat $LOG_FILE
