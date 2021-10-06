# Implantação do SPIRE

Implantar servidor SPIRE:

```bash
kubectl apply -f spire-namespace.yaml
kubectl apply -f server-pv-and-pvc.yaml
kubectl apply -f spire-bundle-configmap.yaml
kubectl apply -f server-account.yaml
kubectl apply -f server-cluster-role.yaml
kubectl apply -f server-configmap.yaml
kubectl apply -f server-service.yaml
kubectl apply -f server-statefulset.yaml
```

Apagar servidor SPIRE:

```bash
kubectl delete -f server-account.yaml
kubectl delete -f server-cluster-role.yaml
kubectl delete -f server-configmap.yaml
kubectl delete -f server-service.yaml
kubectl delete -f server-statefulset.yaml
kubectl delete -f spire-bundle-configmap.yaml
kubectl delete -f spire-namespace.yaml
```

Implantar agente SPIRE:

```bash
kubectl apply -f agent-pv-and-pvc.yaml
kubectl apply -f agent-account.yaml
kubectl apply -f agent-cluster-role.yaml
kubectl apply -f agent-configmap.yaml
kubectl apply -f agent-deployment.yaml
```

Apagar agente SPIRE:

```bash
kubectl delete -f agent-account.yaml
kubectl delete -f agent-cluster-role.yaml
kubectl delete -f agent-configmap.yaml
kubectl delete -f agent-daemonset.yaml
```

# Criar identidades para agentes

```bash
# Agente daemonset
bin/spire-server entry create -spiffeID spiffe://lsd.ufcg.edu.br/agente-k8s -node -selector k8s_sat:agent_ns:spire k8s_sat:agent_sa:spire-agent

bin/spire-server entry create -spiffeID spiffe://lsd.ufcg.edu.br/agente-scone -node -selector k8s_sat:agent_ns:spire k8s_sat:agent_sa:spire-agent-scone
```