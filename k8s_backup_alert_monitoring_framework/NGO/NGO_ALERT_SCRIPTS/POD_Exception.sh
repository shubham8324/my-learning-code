#!/bin/bash

# Set metadata
HOST=$(hostname)
IP=$(hostname -I | awk '{print $1}')
currentDate=$(date +"%Y-%m-%d %H:%M")
log_ts=$(date +"%Y-%m-%d %H:%M")
logfile_ts=$(date +"%Y%m%d%H%M")
LOG_FILE="/app/NGO/Logs/NGO_CUSTOM_UTIL_POD_Error_${logfile_ts}.log"

# Clean previous logs
rm -f /app/NGO/Logs/NGO_CUSTOM_UTIL_POD_Error_*.log

# Define Exception Patterns
EXCEPTION_PATTERNS='I/O error|Caused by|Message VPN Unavailable|java.lang.RuntimeException|Connection reset by peer|Exception message:|IO Error|Connection reset|javax.jms.JMSException|Connection is closed|Error communicating with the router|Service Unavailable|Failed to perform cache operation|I/O error|Connection refused|Connection timed out|The Network Adapter could not establish the connection|UnknownHostException|JCO_ERROR_SYSTEM_FAILURE|Failed to obtain JDBC Connection|DataSource health check failed|connect to|new connection|No route to host|Host unreachable|Read timed out|unexpected connection driver error occured|java.lang.NullPointerException|java.lang.IllegalArgumentException|OPERATION_TIMEOUT|Max clients exceeded for queue|JMS message listener invoker failed|javax.naming.NamingException|AMQPConnectionException|ShutdownSignalException|com.rabbitmq.client.AlreadyClosedException|BrokerUnreachableException|channel is closed|NOT_FOUND - no queue|JCSMPTransportException|SolaceConnectionException|Failed to connect to host|Unable to resolve host|org.apache.kafka.common.KafkaException|TimeoutException|LeaderNotAvailableException|NotLeaderForPartitionException|BrokerNotAvailableException|Connection to node .* could not be established|Disconnected from node|Failed to construct kafka consumer|ORA-[0-9]+|oracle.jdbc.OracleDriver|oracle.net.ns.NetException|oracle.jdbc.pool.OracleDataSource|HttpServerErrorException|HttpClientErrorException|RestClientException|SocketTimeoutException|NoHttpResponseException|ConnectException|SSLHandshakeException|Service temporarily unavailable'

# Loop through all jio namespaces
kubectl get ns | grep -i jio | awk '{print $1}' | while read ns; do
  # Loop through all pods in namespace
  kubectl get pods -n "$ns" --no-headers | awk '{print $1}' | while read podname; do
    # Extract logs and filter for exception lines
    log_output=$(kubectl logs --tail=1000 "$podname" -n "$ns" 2>/dev/null | \
      egrep -i "$EXCEPTION_PATTERNS" | egrep -v 'INFO |#####' | grep "$(date +%Y-%m-%d)")

    # If any errors found
    if [[ -n "$log_output" ]]; then
      # Extract distinct error lines (you can refine this logic)
      echo "$log_output" | while read line; do
        # Extract a simplified exception message (first match group or custom logic)
        Exception=$(echo "$line" | grep -oE 'Invalid API Key|ORA-[0-9]+[^: ]*|[A-Za-z0-9._]*Exception|Caused by[^:]*' | head -1)

        # Fall back if nothing is extracted
        if [[ -z "$Exception" ]]; then
          Exception="UnknownError"
        fi

        # Compose JSON line
        echo "{\"ts\":\"$log_ts\",\"ip\":\"$IP\",\"hname\":\"$HOST\",\"kpi\":\"POD_Exception\",\"value\":\"1\",\"cnt\":\"1\",\"app_sub_name\":\"K8S_PROMQL\",\"kpivalue1\":\"NameSpace-${ns}-PodName-${podname}-Exception-${Exception}\"}" >> "$LOG_FILE"
      done
    fi
  done
done

# Show the result
cat "$LOG_FILE"

