# Demo produtor-consumidor

```bash
# Criar entrada para o produtor
export AGENTE_ID=spiffe://lsd.ufcg.edu.br/spire/agent/k8s_sat/kubernetes/99c16af7-092e-4cfd-8013-0764d9de8663
bin/spire-server entry create \
    -parentID $AGENTE_ID \
    -spiffeID spiffe://lsd.ufcg.edu.br/produtor \
    -selector k8s:container-name:produtor-kafka \
    -selector k8s:ns:default
```