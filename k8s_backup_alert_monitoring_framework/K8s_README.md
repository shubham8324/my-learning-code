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


---

## ⚙️ Features

- **Prometheus Metrics Monitoring**  
  - Monitors CPU, memory, pod status, endpoint availability, HTTP response time, Tomcat threads, and HPA deployment status.
  - IP configuration is centralized in `Prometheus/config/prometheus_servers_config.conf`.
  - Default setup:  
    ```
    Prometheus IP: 10.10.10.10
    Worker IP:     20.20.20.20
    ```

- **Backup & Alerts Monitoring**  
  - Daily configuration backup for deployments, pods, services, and images.
  - Compares image versions across clusters (`Prod1`, `Prod2`, `DR1`, `DR2`).
  - Generates logs in `NGO/Logs` folder.

- **Certificate & Port Monitoring**  
  - Monitors SSL expiry (`ssl_expiry.properties`) and certificates (`kube-config-certificate-expiry.sh`).  
  - Monitors URL/Port availability (`url_monitoring.properties`, `port_monitor.properties`).

- **SSH & Passwordless Setup**  
  - Requires SSH and passwordless connectivity to clusters.
  - Run backup and image version scripts remotely.

---

## 📝 Prerequisites

- **Server Requirements**
  - Linux server (Ubuntu/CentOS/RHEL)
  - `bash`, `ssh`, `scp`, `rsync`, `curl` installed
  - Passwordless SSH setup to all clusters (Prod & DR)

- **Prometheus Configuration**
  - Change IPs in `Prometheus/config/prometheus_servers_config.conf`:
    
    ```text
    prometheus_ip=10.10.10.10
    worker_ip=20.20.20.20
    ```
  - Add matrix/alert whenever a new alert is created. Use **folder name = metric name = script name**.

    ```text
    Metric: container_memory_usage_bytes
    Folder: Prometheus/container_memory_usage_bytes/
    Script: container_memory_usage_bytes_monitor.sh
    ```

- **NGO Script Configuration**
  - Update IPs in `NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts/image_compare/image_compare.sh`:
  - 
    ```bash
    IP_LIST=("Prod1" "Prod2" "DR1" "DR2")
    ssh username@$IP_ADDR ...
    ```
  > Update SSH username in scripts for your environment.

---

## 🛠️ How to Use

### 1️⃣ Prometheus Alerts
- Add metrics in the folder name and script as required. Example metrics:

