
#!/bin/sh


HOST=`hostname`
IP=`hostname -I |awk '{print $1}'`
currentDate=`date +"%Y-%m-%d %H:%M"`

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_kube_pod_created_`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_kube_pod_created_*.log"

# delete the content of file
rm -f $OLD_FILES


source $HOME/.bash_profile;
excl='!'
cd /app/Prometheus/kube_pod_created
> pod_log_curl.txt
> pod_thread.log
config_dir="/app/Prometheus/config/"
config_file=$config_dir"prometheus_servers_config.conf"
metrices_name="kube_pod_created"

for q in `cat $config_file | grep -w $metrices_name |  awk '{print $2"|"$3"|"$4}'`
do
CLUSTER_IP=$(echo $q | awk -F\| '{print $3}')
URL_IP=$(echo $q | awk -F\| '{print $2}')
CLUSTER_NAME=$(echo $q | awk -F\| '{print $1}')

C_URL="http://"$URL_IP"/api/v1/query?query=round(max%20by%20(namespace%2C%20pod)%20(time()%20-%20kube_pod_created%7Bnamespace%3D~%22.*-ebdm-.*%22%7D)%20%2F60)%20%3C%2060"


curl -u admin:'Prometheu$@123' $C_URL | jq '.data.result[] | .metric.namespace  + "|" + .metric.pod  + "|" + .value[1]' | tr -d '"' >> pod_log_curl.txt


file_count=`cat pod_log_curl.txt | wc -l`
if [ $file_count -gt 0 ];
then
for file_output in `cat pod_log_curl.txt`
do
namespace=$(echo $file_output | awk -F\| '{print $1}')
pod=$(echo $file_output | awk -F\| '{print $2}')
count=$(echo $file_output | awk -F\| '{print $3}')
echo $CLUSTER_NAME" "$CLUSTER_IP" "$namespace" "$pod" "$count >> pod_thread.log
ALT_TEXT="PROD ALERT: "$metrices_name", CLUSTER_NAME: "$CLUSTER_NAME", NAMESPACE: "$namespace", pod: "$pod",count: "$count
#echo $ALT_TEXT


echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$metrices_name\",\"value\":\"$count\",\"cnt\":\"$count\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"New pod $pod created in Namespace: namespace. Check if this creation aligns with deployment updates or scaling events.\"}" >> $LOG_FILE

#> pod_log_curl.txt
done
fi
done
#rm -rf pod_log_curl.txt
cat $LOG_FILE

