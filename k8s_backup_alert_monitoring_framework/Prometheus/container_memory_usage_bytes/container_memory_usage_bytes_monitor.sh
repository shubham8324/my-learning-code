#!/bin/sh


HOST=`hostname`
IP=`hostname -I |awk '{print $1}'`
currentDate=`date +"%Y-%m-%d %H:%M"`

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_MEM_`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_MEM_*.log"

# delete the content of file
rm -f $OLD_FILES


source $HOME/.bash_profile;
excl='!'
cd /app/Prometheus/container_memory_usage_bytes
> pod_log_curl.txt
> pod_thread.log
config_dir="/app/Prometheus/config/"
config_file=$config_dir"prometheus_servers_config.conf"
metrices_name="container_memory_usage_bytes"


for q in `cat $config_file | grep -w $metrices_name |  awk '{print $2"|"$3"|"$4}'`
do
CLUSTER_IP=$(echo $q | awk -F\| '{print $3}')
URL_IP=$(echo $q | awk -F\| '{print $2}')
CLUSTER_NAME=$(echo $q | awk -F\| '{print $1}')
OC_TOKEN=`cat "/app/Prometheus/tokens/TOKEN"`

C_URL="http://"$URL_IP"/api/v1/query?query=round%28sort_desc%28sum%28container_memory_working_set_bytes%7Bnamespace%3D~%27.%2A-ebdm-.%2A%27%2Ccontainer%21%3D%22istio-proxy%22%2Ccontainer%21%3D%22POD%22%2Ccontainer%21%3D%22%22%2Ccontainer%21%3D%22istio-proxy%22%2Cimage%21%3D%22%22%7D%2F1024%2F1024%29%20by%20%28namespace%2Cpod%2Ccontainer%29%20%2F%20sum%20%28%20container_spec_memory_limit_bytes%7Bnamespace%3D~%27.%2A-ebdm-.%2A%27%2Ccontainer%21%3D%22istio-proxy%22%2Ccontainer%21%3D%22POD%22%2Ccontainer%21%3D%22%22%2Ccontainer%21%3D%22istio-proxy%22%2Cimage%21%3D%22%22%7D%2F1024%2F1024%29%20by%20%28namespace%2Cpod%2Ccontainer%29%2A100%29%3E50%29"



curl -u admin:'Prometheu$@123' $C_URL | jq '.data.result[] | .metric.namespace + "|" + .metric.pod  + "|" + .metric.container  + "|" + .value[1]' | tr -d '"' >> pod_log_curl.txt


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



echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$metrices_name\",\"value\":\"$thread_count\",\"cnt\":\"$thread_count\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"Memory usage at $thread_count% for PodName: $pod_name and Namespace: $namespace. Check memory allocation, pod limits, and recent trend.\"}" >> $LOG_FILE


#> pod_log_curl.txt
done
fi
done
#rm -rf pod_log_curl.txt
cat $LOG_FILE
