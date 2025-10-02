# 🚀 Kubernetes Backup & Alert Monitoring Framework

A **comprehensive framework** to monitor Kubernetes cluster backups, alerts, Prometheus metrics, and log collection.  

> This project provides scripts, automation, and monitoring tools to ensure your K8s environment is healthy and backup processes are working correctly.

---

## 📁 Project Folder Structure

k8s_backup_alert_monitoring_framework
- ├── NGO
- │ ├── Logs # Logs collected from monitoring scripts
- │ └── NGO_ALERT_SCRIPTS
- │ ├── Daily_Config_Backup_Scripts
- │ │ ├── config_prop_backup
- │ │ ├── deployment_backup
- │ │ ├── EBDM_Backup_Failed_K8s.sh
- │ │ ├── image_compare # Compare image versions across clusters
- │ │ ├── Image_version_backup
- │ │ ├── pod_backup
- │ │ └── SVC_backup
- │ ├── hpa_monitor.sh
- │ ├── K8s_Liveness_probe_missing.sh
- │ ├── K8s_Readiness_probe_missing.sh
- │ ├── kube-config-certificate-expiry.sh
- │ ├── nettest.sh
- │ ├── POD_Exception.sh
- │ ├── pod_monitor.sh
- │ ├── Port_Monitoring.sh
- │ ├── port_monitor.properties
- │ ├── ssl_expiry.properties
- │ ├── SSL_EXPIRY.sh
- │ ├── url_monitoring.properties
- │ └── url_monitoring.sh
- └── Prometheus
- ├── config # Prometheus configuration
- ├── container_cpu_usage_seconds_total
- ├── container_memory_usage_bytes
- ├── Deployment_HPA_Missing
- ├── endpoint_not_available
- ├── http_request_count
- ├── HTTP_RESPONSE_TIME_MONITOR
- ├── kube_pod_created
- ├── pod_not_running
- └── TOMCAT_THREADS_CURRENT_THREADS
