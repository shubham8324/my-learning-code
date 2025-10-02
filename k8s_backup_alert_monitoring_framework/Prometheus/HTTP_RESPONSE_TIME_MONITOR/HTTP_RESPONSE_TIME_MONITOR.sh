
#!/bin/sh


HOST=`hostname`
IP=`hostname -I |awk '{print $1}'`
currentDate=`date +"%Y-%m-%d %H:%M"`

LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_RESPONSE_`date +"%Y%m%d%H%M"`.log"
OLD_FILES="/app/NGO/Logs/NGO_CUSTOM_UTIL_K8S_RESPONSE_*.log"

# delete the content of file
rm -f $OLD_FILES


source $HOME/.bash_profile;
excl='!'
cd /app/Prometheus/HTTP_RESPONSE_TIME_MONITOR
> pod_log_curl.txt
> pod_response.log
config_dir="/app/Prometheus/config/"
config_file=$config_dir"prometheus_servers_config.conf"
metrices_name="HTTP_RESPONSE_TIME_MONITOR"

for q in `cat $config_file | grep -w $metrices_name |  awk '{print $2"|"$3"|"$4}'`
do
CLUSTER_IP=$(echo $q | awk -F\| '{print $3}')
URL_IP=$(echo $q | awk -F\| '{print $2}')
CLUSTER_NAME=$(echo $q | awk -F\| '{print $1}')

C_URL="http://"$URL_IP"/api/v1/query?query=round(sort_desc(sum(irate(%7B__name__%3D~%22%5E.*seconds_sum.*%22%2Cstatus%3D%22200%22%2Curi!%3D%22%2Factuator%2Fprometheus%22%2Curi!%3D%22%22%7D%5B5m%5D)%20*1000)by%20(app%2Ckubernetes_namespace%2Curi)%2Fsum(irate(%7B__name__%3D~%22%5E.*seconds_count.*%22%2Cstatus%3D%22200%22%2Curi!%3D%22%2Factuator%2Fprometheus%22%2Curi!%3D%22%22%7D%5B5m%5D))%20by%20(app%2Ckubernetes_namespace%2Curi)%20%3E%205000))"


curl -u admin:'Prometheu$@123' $C_URL | jq '.data.result[] | .metric.app + "|" + .metric.kubernetes_namespace  + "|" + .metric.uri  + "|" + .value[1]' | tr -d '"' >> pod_log_curl.txt


file_count=`cat pod_log_curl.txt | wc -l`
if [ $file_count -gt 0 ];
then
for file_output in `cat pod_log_curl.txt`
do
namespace=$(echo $file_output | awk -F\| '{print $2}')
app=$(echo $file_output|  awk -F\| '{print $1}')
uri=$(echo $file_output|  awk -F\| '{print $3}')
count=$(echo $file_output | awk -F\| '{print $4}')
echo $CLUSTER_NAME" "$CLUSTER_IP" "$namespace" "$app" "$uri" "$count >> pod_response.log
ALT_TEXT="PROD ALERT: "$metrices_name", CLUSTER_NAME: "$CLUSTER_NAME", NAMESPACE: "$namespace", app: "$app", uri: "$uri",count: "$count
echo $ALT_TEXT


echo "{\"ts\":\"$currentDate\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"$metrices_name\",\"value\":\"$count\",\"cnt\":\"$count\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"Response time $count observed for $uri in Service: $app (Namespace: $namespace). Check backend latency and API performance metrics.\"}" >> $LOG_FILE


#> pod_log_curl.txt
done
fi
done
#rm -rf pod_log_curl.txt
cat $LOG_FILE

