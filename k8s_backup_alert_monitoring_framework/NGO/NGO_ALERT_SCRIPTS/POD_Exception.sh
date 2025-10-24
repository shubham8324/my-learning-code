#!/bin/bash

# Load IP and Hostname configuration
source /app/NGO/NGO_ALERT_SCRIPTS/config/ip.txt

if [[ -n "$HARDCODED_IP" ]]; then
    IP="$HARDCODED_IP"
else
    IP=$(eval "$DYNAMIC_IP_CMD")
fi

if [[ -n "$HARDCODED_HOSTNAME" ]]; then
    HOST="$HARDCODED_HOSTNAME"
else
    HOST=$(eval "$DYNAMIC_HOSTNAME_CMD")
fi

log_ts=$(date +"%Y-%m-%d %H:%M")
logfile_ts=$(date +"%Y%m%d%H%M")
LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_POD_Error_${logfile_ts}.log"

rm -f /app/NGO/Logs/NGO_CUSTOM_UTIL_POD_Error_*.log

EXCEPTION_PATTERNS='I/O error|Caused by|Message VPN Unavailable|java.lang.RuntimeException|Connection reset by peer|Exception message:|IO Error|Connection reset|javax.jms.JMSException|Connection is closed|Error communicating with the router|Service Unavailable|Failed to perform cache operation|Connection refused|Connection timed out|The Network Adapter could not establish the connection|UnknownHostException|JCO_ERROR_SYSTEM_FAILURE|Failed to obtain JDBC Connection|DataSource health check failed|connect to|new connection|No route to host|Host unreachable|Read timed out|unexpected connection driver error occured|java.lang.NullPointerException|java.lang.IllegalArgumentException|OPERATION_TIMEOUT|Max clients exceeded for queue|JMS message listener invoker failed|javax.naming.NamingException|AMQPConnectionException|ShutdownSignalException|com.rabbitmq.client.AlreadyClosedException|BrokerUnreachableException|channel is closed|NOT_FOUND - no queue|JCSMPTransportException|SolaceConnectionException|Failed to connect to host|Unable to resolve host|org.apache.kafka.common.KafkaException|TimeoutException|LeaderNotAvailableException|NotLeaderForPartitionException|BrokerNotAvailableException|Connection to node .* could not be established|Disconnected from node|Failed to construct kafka consumer|ORA-[0-9]+|oracle.jdbc.OracleDriver|oracle.net.ns.NetException|oracle.jdbc.pool.OracleDataSource|HttpServerErrorException|HttpClientErrorException|RestClientException|SocketTimeoutException|NoHttpResponseException|ConnectException|SSLHandshakeException|Service temporarily unavailable'

tmp_file=$(mktemp)

kubectl get ns | grep -i jio | awk '{print $1}' | while read -r ns; do
  kubectl get pods -n "$ns" --no-headers | awk '{print $1}' | while read -r podname; do
    log_output=$(kubectl logs --since=2h "$podname" -n "$ns" 2>/dev/null | \
      egrep -i "$EXCEPTION_PATTERNS" | egrep -v 'INFO |#####')

    if [[ -n "$log_output" ]]; then
      echo "$log_output" | while read -r line; do
        Exception=$(echo "$line" | grep -oE 'Invalid API Key|ORA-[0-9]+[^: ]*|[A-Za-z0-9._]*Exception|Caused by[^:]*' | head -1)
        [[ -z "$Exception" ]] && Exception="UnknownError"

        # Write key for counting
        echo "NameSpace: ${ns}, PodName: ${podname}, Exception: ${Exception}" >> "$tmp_file"
      done
    fi
  done
done

if [[ -s "$tmp_file" ]]; then
  # Count occurrences of each unique key
  declare -A counts
  while read -r line; do
    counts["$line"]=$((counts["$line"] + 1))
  done < "$tmp_file"

  total_count=0
  kpivalue1=""

  for key in "${!counts[@]}"; do
    c=${counts[$key]}
    total_count=$((total_count + c))
    kpivalue1+="${key}, Count: ${c}; "
  done

  echo "{\"ts\":\"$log_ts\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"POD_Exception\",\"value\":\"$total_count\",\"cnt\":\"$total_count\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"$kpivalue1\"}" > "$LOG_FILE"
else
  echo "{\"ts\":\"$log_ts\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"POD_Exception\",\"value\":\"0\",\"cnt\":\"0\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"No exceptions found in the last 2 hours.\"}" > "$LOG_FILE"
fi

rm -f "$tmp_file"
cat "$LOG_FILE"

