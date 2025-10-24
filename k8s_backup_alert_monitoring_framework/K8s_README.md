# 🚀 k8s_backup_alert_monitoring_framework

![Kubernetes Logo](https://upload.wikimedia.org/wikipedia/commons/3/39/Kubernetes_logo_without_workmark.svg)
> **A lightweight, modular monitoring & alerting framework for Kubernetes backups and daily checks**

---

## 🔗 Quick Links
- [📘 Introduction](#-introduction)
- [🧠 Languages Used](#-languages-used)
- [🌟 Project Highlights / Use Cases](#-project-highlights--use-cases)
- [📁 Folder Structure](#-project-folder-structure)
- [✨ Features](#-features)
- [📝 Prerequisites](#-prerequisites)
- [🛠️ How to Use](#️-how-to-use)
- [💡 Tips & Best Practices](#-tips--best-practices)

---

## 📘 Introduction
The **k8s_backup_alert_monitoring_framework** automates:
- Kubernetes backup validation  
- Alert monitoring and notification
- Configuration verification  
- Daily comparison reports between clusters  

It ensures consistency, reliability, and readiness across Production (PROD) and Disaster Recovery (DR) environments, reducing manual operational overhead.
---

## 💡 Why Use This Framework
✅ Centralized alert monitoring  
✅ Automated configuration & backup checks  
✅ Seamless integration with Prometheus & NGO alert scripts  
✅ Reduces manual intervention, improving operational efficiency  
✅ Simple configuration-driven design  

---

## 🧠 Languages Used
- 🐚 **Shell Script** (Core automation logic)  
- ☁️ **YAML / Config files** (Cluster & Prometheus configurations)

> 💾 *Usage and downloads metrics available via GitHub insights.*

---

## 🌟 Project Highlights / Use Cases

- 🧩 **Kubernetes Deployment Image Comparison**  
  - Ensures container image and configuration consistency between PROD and DR clusters.

- 📡 **Prometheus-Based Alert Monitoring**  
  - Continuously tracks metrics such as CPU, memory, Pod health, HTTP response times, and HPA deployment status.

- 🔍 **Critical Component Validation**  
  - Verifies the health and availability of pods, endpoints, and deployments to ensure system reliability.

- ⚙️ **Environment-Agnostic Configuration**  
  - Works seamlessly across multiple Kubernetes clusters with simple centralized configuration.

- 🚀 **Operational Automation**  
  - Automates daily health checks, backups, and cluster synchronization validations.

---

## 📁 Project Folder Structure

k8s_backup_alert_monitoring_framework/
├── NGO/  
│   ├── Logs/  
│   └── NGO_ALERT_SCRIPTS/  
│       ├── config/  
│       │   └── ip.txt  
│       ├── Daily_Config_Backup_Scripts/  
│       │   ├── config_prop_backup/  
│       │   │   └── all_properties/  
│       │   ├── Daily_Config_Backup_Scripts.sh  
│       │   ├── deployment_backup/  
│       │   │   ├── All_Deployment_backup/  
│       │   │   └── All_Deployment_yaml_backup/  
│       │   ├── EBDM_Backup_Failed_K8s.sh  
│       │   ├── image_compare/  
│       │   │   ├── Image_15min_diff.sh  
│       │   │   ├── image_compare.sh  
│       │   ├── Image_version_backup/  
│       │   ├── pod_backup/  
│       │   └── SVC_backup/  
│       ├── hpa_monitor.sh  
│       ├── K8s_Liveness_probe_missing.sh  
│       ├── K8s_Readiness_probe_missing.sh  
│       ├── kube-config-certificate-expiry.sh  
│       ├── nettest.sh  
│       ├── POD_Exception.sh  
│       ├── pod_monitor.sh  
│       ├── Port_Monitoring.sh  
│       ├── port_monitor.properties  
│       ├── ssl_expiry.properties  
│       ├── SSL_EXPIRY.sh  
│       ├── url_monitoring.properties  
│       └── url_monitoring.sh  
├── Prometheus/  
│   ├── config/  
│   │   ├── ip.txt  
│   │   └── prometheus_servers_config.conf  
│   ├── container_cpu_usage_seconds_total/  
│   │   ├── container_cpu_usage_bytes_monitor.sh  
│   ├── container_memory_usage_bytes/  
│   │   ├── container_memory_usage_bytes_monitor.sh  
│   ├── Deployment_HPA_Missing/  
│   │   ├── Deployment_HPA_Missing.sh  
│   ├── endpoint_not_available/  
│   │   ├── endpoint_not_available.sh  
│   ├── http_request_count/  
│   │   ├── http_request_count.sh  
│   ├── HTTP_RESPONSE_TIME_MONITOR/  
│   │   ├── HTTP_RESPONSE_TIME_MONITOR.sh  
│   ├── kube_pod_created/  
│   │   ├── kube_pod_created.sh  
│   ├── pod_not_running/  
│   │   ├── pod_not_running.sh  
│   └── TOMCAT_THREADS_CURRENT_THREADS/  
│       └── TOMCAT_THREADS_CURRENT_THREADS.sh  


---

## ✨ Features

- 🔭 **Prometheus Metrics Monitoring**
  - Tracks key Kubernetes metrics: CPU, memory, pod status, endpoint availability, HTTP response time, Tomcat threads, and HPA deployment status.  
  - Configuration via: Prometheus/config/prometheus_servers_config.conf

- 💾 **Backup & Alerts Monitoring**
  - Daily backups for deployments, pods, services, and images
  - Cross-cluster image comparison (PROD1, PROD2, DR1, DR2)
  - Logs stored under NGO/Logs

- 🔐 **Certificate & Port Monitoring**
  - SSL certificate expiry validation (ssl_expiry.properties)  
  - K8s config certificate monitoring (kube-config-certificate-expiry.sh)
  - URL & port availability checks (url_monitoring.properties & port_monitor.properties)
 
- 🔗 **SSH & Passwordless Access**
  - Executes scripts remotely for backup, alerting, and comparisons across clusters securely.

- 🧩 **Flexible Configuration**
  - Modular and easy-to-edit environment variables for rapid scaling and customization.

- 🛡️ **DR Readiness Validation**
  - Ensures synchronization between PROD and DR environments to detect missing/outdated components before failover.

- 📊 **Comprehensive Logging**
  - Logs all alerts, monitoring reports, and script outputs in NGO/Logs for debugging, auditing, and review.
    
- ⚙️ **Lightweight & Extensible Design**
  - Pure Shell Script design for minimal dependencies and easy integration with any monitoring tools.


---

## 📝 Prerequisites

> ⚠️ **Before running**, make sure to apply the following configuration changes:

1. Update Configuration Files
- Prometheus/config/ip.txt & NGO/NGO_ALERT_SCRIPTS/config/ip.txt

Replace the below variables:
```bash
HARDCODED_IP=your_IP
HARDCODED_HOSTNAME=your_hostname
```

2. Update Prometheus Config
- File: Prometheus/config/prometheus_servers_config.conf

Replace all your_IP and Prometheus_IP with your actual IPs:
```bash
container_memory_usage_bytes EBDM2.0_FTTX Prometheus_IP:30900 your_IP
container_cpu_usage_seconds_total EBDM2.0_FTTX Prometheus_IP:30900 your_IP
TOMCAT_THREADS_CURRENT_THREADS EBDM2.0_FTTX Prometheus_IP:30900 your_IP
...
```

3. Update Cluster IPs for Image Comparison
-File: NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts/image_compare/image_compare.sh

> Define cluster IP groups
> IP_LIST  → List of all cluster nodes
> PROD_IPS → Active/Primary cluster IPs
> DR_IPS   → Passive/Disaster Recovery cluster IPs

IP_LIST=("IP1" "IP2" "IP3" "IP4")
PROD_IPS=("Active_IP1" "Active_IP2")
DR_IPS=("Passive_IP1" "Passive_IP2")


4. SSH Username Update
- Change "your_user_name" to your actual username

ssh -o BatchMode=yes -o ConnectTimeout=10 your_user_name@"$IP_ADDR" cat "$SRC_FILE" > "$TARGET_DIR/image_info.txt" 2>/dev/null


5. Server Requirements
  - Linux server (Ubuntu/CentOS/RHEL)
  - `bash`, `ssh`, `scp`, `rsync`, `curl` installed
  - Passwordless SSH setup to all clusters (Prod & DR)
    

6. SSL & Port Monitoring

- Update: Update mention properties to use these script

```Bash
port_monitor.properties → #website|IP|appname|port
url_monitoring.properties → #hostname port
ssl_expiry.properties → #website|IP|hostname|port
Update certificates in kube-config-certificate-expiry.sh.
```


---

## 🛠️ How to Use

- Extract this sub-repo into your working directory:

```bash
git clone https://github.com/shubham8324/my-learning-code
cd my-learning-code/k8s_backup_alert_monitoring_framework
```

1. Apply the prerequisite changes above.

2. Run your alert or backup scripts as per configuration:

./NGO/NGO_ALERT_SCRIPTS/Daily_Config_Backup_Scripts/image_compare/image_compare.sh

3. Check logs & reports under output/ or logs/ folder.
    

---

💡 Tips & Best Practices

- 🔍 Validate IPs, hostnames & credentials before running scripts
- 💾 Maintain backups of configuration files
- ⏰ Use cron jobs for daily automation
- 📡 Verify Prometheus connectivity before enabling alerts
- 🔁 Keep PROD and DR configs synchronized
- 📂 Maintain consistent folder, metric & script naming conventions
- 🔑 Enable passwordless SSH for smooth operations
 
-----

📫 Author

🖋️ Shubham Patel 🚀 Happy Monitoring!

> Automate, standardize, and simplify Kubernetes backup and alert monitoring.
