
#!/bin/sh


HOST=`hostname`
IP=`hostname -I |awk '{print $1}'`
currentDate=`date +"%Y-%m-%d %H:%M"`

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_endpoint_not_available_`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_endpoint_not_available_*.log"

# delete the content of file
rm -f $OLD_FILES


source $HOME/.bash_profile;
excl='!'
cd /app/Prometheus/endpoint_not_available
> pod_log_curl.txt
> pod_thread.log
config_dir="/app/Prometheus/config/"
config_file=$config_dir"prometheus_servers_config.conf"
metrices_name="endpoint_not_available"

for q in `cat $config_file | grep -w $metrices_name |  awk '{print $2"|"$3"|"$4}'`
do
CLUSTER_IP=$(echo $q | awk -F\| '{print $3}')
URL_IP=$(echo $q | awk -F\| '{print $2}')
CLUSTER_NAME=$(echo $q | awk -F\| '{print $1}')

C_URL="http://"$URL_IP"/api/v1/query?query=max%20by%20(namespace%2C%20endpoint%2C%20kubernetes_pod_name)%20(kube_endpoint_address_available%7Bnamespace%3D~%22.*-ebdm-.*%22%7D%3C%3D0)"


curl -u admin:'Prometheu$@123' $C_URL | jq '.data.result[] | .metric.namespace  + "|" + .metric.endpoint  + "|" + .metric.kubernetes_pod_name   + "|" + .value[1]' | tr -d '"' >> pod_log_curl.txt


file_count=`cat pod_log_curl.txt | wc -l`
if [ $file_count -gt 0 ];
then
for file_output in `cat pod_log_curl.txt`
do
namespace=$(echo $file_output | awk -F\| '{print $1}')
endpoint=$(echo $file_output|  awk -F\| '{print $2}')
count=$(echo $file_output | awk -F\| '{print $4}')
echo $CLUSTER_NAME" "$CLUSTER_IP" "$namespace" "$endpoint" "$endpoint" "$count >> pod_thread.log
ALT_TEXT="PROD ALERT: "$metrices_name", CLUSTER_NAME: "$CLUSTER_NAME", NAMESPACE: "$namespace", endpoint: "$endpoint",count: "$count
echo $ALT_TEXT


echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$metrices_name\",\"value\":\"$count\",\"cnt\":\"$count\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"Service endpoint $endpoint is unavailable (Namespace: $namespace). Check service and pod availability.\"}" >> $LOG_FILE

#> pod_log_curl.txt
done
fi
done
#rm -rf pod_log_curl.txt
cat $LOG_FILE

