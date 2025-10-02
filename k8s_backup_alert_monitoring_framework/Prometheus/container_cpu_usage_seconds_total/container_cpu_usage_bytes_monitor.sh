#!/bin/sh


HOST=`hostname`
IP=`hostname -I |awk '{print $1}'`
currentDate=`date +"%Y-%m-%d %H:%M"`

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_CPU_`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_CPU_*.log"

# delete the content of file
rm -f $OLD_FILES


source $HOME/.bash_profile;
excl='!'
cd /app/Prometheus/container_cpu_usage_seconds_total
> pod_log_curl.txt
> pod_CPU.log
config_dir="/app/Prometheus/config/"
config_file=$config_dir"prometheus_servers_config.conf"
metrices_name="container_cpu_usage_seconds_total"

for q in `cat $config_file | grep -w $metrices_name |  awk '{print $2"|"$3"|"$4}'`
do
CLUSTER_IP=$(echo $q | awk -F\| '{print $3}')
URL_IP=$(echo $q | awk -F\| '{print $2}')
CLUSTER_NAME=$(echo $q | awk -F\| '{print $1}')
OC_TOKEN=`cat "/app/Prometheus/tokens/TOKEN"`

C_URL="http://"$URL_IP"/api/v1/query?query=round(sort_desc(avg(rate(container_cpu_usage_seconds_total%7Bnamespace%3D~%27.*ebdm-.*%27%2Ccontainer!%3D%22istio-proxy%22%2Ccontainer!%3D%22POD%22%2Ccontainer!%3D%22%22%2Ccontainer!%3D%22istio-proxy%22%2Cimage!%3D%22%22%7D%5B5m%5D)*100)%20by%20(namespace%2Cpod%2Ccontainer)%3E1))%0A"


curl -u admin:'Prometheu$@123' $C_URL | jq '.data.result[] | .metric.namespace + "|" + .metric.pod  + "|" + .metric.container  + "|" + .value[1]' | tr -d '"' >> pod_log_curl.txt


file_count=`cat pod_log_curl.txt | wc -l`
if [ $file_count -gt 0 ];
then
for file_output in `cat pod_log_curl.txt`
do
namespace=$(echo $file_output | awk -F\| '{print $1}')
pod_name=$(echo $file_output|  awk -F\| '{print $2}')
container_name=$(echo $file_output|  awk -F\| '{print $3}')
CPU_count=$(echo $file_output | awk -F\| '{print $4}')
echo $CLUSTER_NAME" "$CLUSTER_IP" "$namespace" "$pod_name" "$CPU_count >> pod_CPU.log
ALT_TEXT="OC PROD ALERT:"$metrices_name",CLUSTER_NAME:"$CLUSTER_NAME",NAMESPACE:"$namespace",POD_NAME:"$pod_name",Container:"$container_name",MEM_PERCENTAGE:"$CPU_count
#echo $ALT_TEXT


echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$metrices_name\",\"value\":\"$CPU_count\",\"cnt\":\"$CPU_count\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"CPU usage exceeded $CPU_count% for PodName: $pod_name and Namespace: $namespace. Investigate workload or optimize CPU requests/limits.\"}" >> $LOG_FILE

done
fi
done

cat $LOG_FILE

