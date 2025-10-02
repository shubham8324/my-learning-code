#!/bin/bash
HOST=`hostname`
IP=`hostname -I| awk '{print $1}'`
currentDate=`date +"%Y-%m-%d %H:%M"`

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_KUBE_CONFIG_CERTIFICATE_EXPIRY`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_KUBE_CONFIG_CERTIFICATE_EXPIRY*.log"


# delete the content of file
rm -f $OLD_FILES
currentd=`date +%s`
EXPIRE=$(/bin/openssl x509 -in ~/.kube/sslagent.cert -noout -text |grep "Not After" |awk '{print $4 " " $5 " " $6 " " $7 " " $8}')
expiredate=$(date -d "${EXPIRE}" +%s)
expdate=$(($expiredate - $currentd))
expday=$((${expdate} / 86400))
echo $expday
KPI1="KUBE_CONFIG_CERTIFICATE_EXPIRY"

#Pirnt the NGO Data if KPI count is greater than 0 for alert
if [[ $expday -gt 0 ]];
then
echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$KPI1\",\"value\":\"$expday\",\"cnt\":\"$expday\",\"app_sub_name\":\"K8S_MONITOR\",\"value1:\"Kubernetes config certificate expires in $expday days. Check certificate details and renewal readiness.\"}" >> $LOG_FILE

fi
cat $LOG_FILE



