for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep -- '-ebdm-'); do
  echo "Namespace: $ns"
  kubectl get pods -n "$ns" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{range .spec.containers[*]}{.name}{"\n"}{"Liveness: "}{.livenessProbe}{"\n"}{"Readiness: "}{.readinessProbe}{"\n"}{"---\n"}{end}{end}'
done
