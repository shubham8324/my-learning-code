#!/bin/sh

# Load variables from ip.txt
source /app/Prometheus/config/ip.txt

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

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_THREAD_`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_THREAD_*.log"

# delete the content of file
rm -f $OLD_FILES


source $HOME/.bash_profile;
excl='!'
cd /app/Prometheus/TOMCAT_THREADS_CURRENT_THREADS
> pod_log_curl.txt
> pod_thread.log
config_dir="/app/Prometheus/config/"
config_file=$config_dir"prometheus_servers_config.conf"
metrices_name="TOMCAT_THREADS_CURRENT_THREADS"

for q in `cat $config_file | grep -w $metrices_name |  awk '{print $2"|"$3"|"$4}'`
do
CLUSTER_IP=$(echo $q | awk -F\| '{print $3}')
URL_IP=$(echo $q | awk -F\| '{print $2}')
CLUSTER_NAME=$(echo $q | awk -F\| '{print $1}')


URL_IP=$(echo $q | awk -F\| '{print $2}')
C_URL="http://"$URL_IP"/api/v1/query?query=sort_desc(round(sum%20by%20(kubernetes_namespace%2C%20kubernetes_pod_name)%20((tomcat_threads_current_threads%7Bkubernetes_namespace%3D~%27.*ebdm-.*%27%7D%2Ftomcat_threads_config_max_threads%7Bkubernetes_namespace%3D~%27.*ebdm-.*%27%7D)*100))%3E5)"


curl -u admin:'Prometheu$@123' $C_URL | jq '.data.result[] | .metric.kubernetes_namespace + "|" + .metric.kubernetes_pod_name  + "|" + .metric.container  + "|" + .value[1]' | tr -d '"' >> pod_log_curl.txt


file_count=`cat pod_log_curl.txt | wc -l`
if [ $file_count -gt 0 ];
then
for file_output in `cat pod_log_curl.txt`
do
namespace=$(echo $file_output | awk -F\| '{print $1}')
pod_name=$(echo $file_output|  awk -F\| '{print $2}')
container_name=$(echo $file_output|  awk -F\| '{print $3}')
thread_count=$(echo $file_output | awk -F\| '{print $4}')
echo $CLUSTER_NAME" "$CLUSTER_IP" "$namespace" "$pod_name" "$thread_count >> pod_thread.log
ALT_TEXT="OC PROD ALERT:"$metrices_name",CLUSTER_NAME:"$CLUSTER_NAME",NAMESPACE:"$namespace",POD_NAME:"$pod_name",Container:"$container_name",MEM_PERCENTAGE:"$thread_count
#echo $ALT_TEXT


echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$metrices_name\",\"value\":\"$thread_count\",\"cnt\":\"$thread_count\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"Tomcat threads reached $thread_count% usage in Service: $pod_name and Namespace: $namespace. Check active thread count and request load.\"}" >> $LOG_FILE


done
fi
done

cat $LOG_FILE


