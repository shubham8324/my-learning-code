# 💡 30 Advanced `kubectl` Commands Every Cloud Engineer Should Master

⚙️ As a **Kubernetes SME**, I’ve seen how knowing the right commands can save hours during troubleshooting, scaling, or optimizing clusters.  
Here’s a list of **30 powerful & practical kubectl commands** that go beyond the basics 👇👇👇👇👇👇👇👇👇👇👇

---

## 🔹 Cluster & Context Management

```bash
1️⃣ kubectl config view --minify | grep name:
# → Show current cluster context

2️⃣ kubectl config use-context <context>
# → Switch between clusters quickly

3️⃣ kubectl cluster-info dump
# → Deep cluster details for debugging
```

## 🔹 Pods Deep Dive
```bash
4️⃣ kubectl get pods -o wide
# → Show pods with node/IP mapping

5️⃣ kubectl get pod <pod> -o yaml
# → Full YAML for pod inspection

6️⃣ kubectl describe pod <pod>
# → Debug pod lifecycle/events

7️⃣ kubectl exec -it <pod> -- /bin/bash
# → Access pod shell directly

8️⃣ kubectl cp <pod>:<path> <local-path>
# → Copy data in/out of a pod

```

## 🔹 Logs & Troubleshooting
```bash

9️⃣  kubectl logs <pod>
# → Get live logs

🔟  kubectl logs -f <pod> --tail=100
# → Stream last 100 lines

1️⃣1️⃣ kubectl logs <pod> -c <container>
# → Logs of specific container in a pod

```


## 🔹 Deployments & Rollouts
```bash

1️⃣2️⃣ kubectl get deployments
# → Check deployments health

1️⃣3️⃣ kubectl rollout status deployment/<name>
# → Watch rollout in real-time

1️⃣4️⃣ kubectl rollout undo deployment/<name>
# → Rollback to last version

1️⃣5️⃣ kubectl scale deployment <name> --replicas=5
# → Scale instantly

```

## 🔹 Nodes & Resources
```bash

1️⃣6️⃣ kubectl get nodes -o wide
# → Show nodes with capacity info

1️⃣7️⃣ kubectl top nodes
# → Node-level CPU & memory metrics

1️⃣8️⃣ kubectl cordon <node>
# → Mark node unschedulable

1️⃣9️⃣ kubectl drain <node> --ignore-daemonsets
# → Evict pods safely

```


## 🔹 Namespaces & Access

```bash

2️⃣0️⃣ kubectl get ns
# → List namespaces

2️⃣1️⃣ kubectl create ns <name>
# → Create new namespace

2️⃣2️⃣ kubectl config set-context --current --namespace=<ns>
# → Default namespace switch
```

## 🔹 Secrets & Configs
```bash

2️⃣3️⃣ kubectl get secrets
# → Check available secrets

2️⃣4️⃣ kubectl create secret generic <name> --from-literal=key=value
# → Quick secret creation

2️⃣5️⃣ kubectl describe secret <name>
# → Secret details
```

## 🔹 Services & Networking
```bash

2️⃣6️⃣ kubectl get svc -o wide
# → Expose service mapping & IPs

2️⃣7️⃣ kubectl port-forward svc/<name> 8080:80
# → Access service locally

2️⃣8️⃣ kubectl describe ingress <name>
# → Ingress routing deep dive
```

## 🔹 Debug & Cleanup
```bash
2️⃣9️⃣ kubectl debug node/<node> -it --image=busybox
# → Run ephemeral debug pod

3️⃣0️⃣ kubectl delete pod <pod> --grace-period=0 --force
# → Force kill stuck pods
```


## 💡 Pro-Tips 📌

1️⃣ Combine JSONPath for scripting

> kubectl get <resource> -o jsonpath=...


2️⃣ Use alias for speed

> alias k=kubectl


3️⃣ Structure clusters properly

> Keep dev, test, and prod isolated for safety and governance.

4️⃣ Monitor systems smartly

> Integrate Prometheus and Grafana for observability.

5️⃣ Automate backups regularly

> Prevent downtime by backing up configs, manifests, and etcd data.


## 🧾 Author Note

💻 These notes are part of my learning journey — documenting real-world Kubernetes administration, automation, and troubleshooting.

✍️ Author: Shubham (Cloud & DevOps support Engineer)

🔗 Repo: my-learning-code



