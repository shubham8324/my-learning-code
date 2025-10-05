---
title: "💡 30 Advanced kubectl Commands Every Cloud Engineer Should Master"
author: "Hanu | Cloud & DevOps Engineer"
tags: ["Kubernetes", "kubectl", "Cloud", "DevOps", "Troubleshooting", "SRE", "Automation"]
---

# 💡 30 Advanced `kubectl` Commands Every Cloud Engineer Should Master  

> ⚙️ As a **Kubernetes SME**, I’ve seen how mastering the right commands can save hours — during troubleshooting, scaling, or optimizing production workloads.  
> These are my **top 30 practical, advanced `kubectl` commands** that go far beyond the basics 👇  

---

## 🔹 Cluster & Context Management  

```bash
# Show current cluster context
kubectl config view --minify | grep name:

# Switch between clusters
kubectl config use-context <context>

# Dump detailed cluster info for debugging
kubectl cluster-info dump


🔹 Pods Deep Dive
# Show pods with node/IP mapping
kubectl get pods -o wide

# Get full YAML definition of a pod
kubectl get pod <pod> -o yaml

# Describe pod lifecycle and events
kubectl describe pod <pod>

# Access pod shell directly
kubectl exec -it <pod> -- /bin/bash

# Copy data between pod and local
kubectl cp <pod>:<path> <local-path>


🔹 Logs & Troubleshooting

# Get pod logs
kubectl logs <pod>

# Stream last 100 lines of logs
kubectl logs -f <pod> --tail=100

# Logs from specific container in a pod
kubectl logs <pod> -c <container>


🔹 Deployments & Rollouts

# Check deployments health
kubectl get deployments

# Watch rollout progress in real time
kubectl rollout status deployment/<name>

# Rollback to last version
kubectl rollout undo deployment/<name>

# Scale replicas instantly
kubectl scale deployment <name> --replicas=5


🔹 Nodes & Resources

# Show nodes with resource details
kubectl get nodes -o wide

# Display CPU & memory usage
kubectl top nodes

# Mark node unschedulable
kubectl cordon <node>

# Evict pods safely for maintenance
kubectl drain <node> --ignore-daemonsets


🔹 Namespaces & Access
# List all namespaces
kubectl get ns

# Create a new namespace
kubectl create ns <name>

# Set a default namespace for current context
kubectl config set-context --current --namespace=<ns>



🔹 Secrets & Configs

# View all secrets
kubectl get secrets

# Create secret from literal values
kubectl create secret generic <name> --from-literal=key=value

# Describe a specific secret
kubectl describe secret <name>


🔹 Services & Networking
# Expose service details and mapping
kubectl get svc -o wide

# Access service locally
kubectl port-forward svc/<name> 8080:80

# Inspect ingress routing and rules
kubectl describe ingress <name>


🔹 Debug & Cleanup
# Run ephemeral debug pod on a node
kubectl debug node/<node> -it --image=busybox

# Force delete a stuck pod immediately
kubectl delete pod <pod> --grace-period=0 --force



💡 Pro Tips for Real-World Usage

🔥 1. Automate with JSONPath
Combine commands like:
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

for dynamic scripting.

⚡ 2. Use Aliases
Alias kubectl as k to save typing:
alias k=kubectl


🧩 3. Isolate Environments
Use dev / test / prod namespaces for better control and RBAC separation.

📊 4. Monitor Like a Pro
Integrate Prometheus + Grafana for real-time insights into your cluster.

🧠 5. Automate Backups
Regular etcd and resource backups prevent major downtime.


🧭 Bonus Tip: Build Your Own K8s Toolbox

Create a personal GitHub repo — something like K8s-Toolbox or CloudXP-Notes —
to version-control your favorite commands, scripts, and playbooks.

That’s how your journey evolves from “I use kubectl” ➡️ “I engineer Kubernetes.” 💪


🚀 Follow for More

☁️ Cloud Architecture | ⚙️ Kubernetes | 🧠 Automation | 🔐 DevSecOps
