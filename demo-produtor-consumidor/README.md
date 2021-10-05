# Demo produtor-consumidor

Nesse momento, você já deve ter recebido dados de acesso à máquina virtual com todas as ferramentas necessárias para excutar a demonstração.

Faça login na máquina via SSH. Assumindo um sistema operacional UNIX, o seguinte comando deve fazer isso.

```bash
export USERNAME=<user> # substitua <user> pelo nome de usuário que você recebeu
export CERTDIR=<cert-dir> # substitua <cert-dir> pelo caminho para o certificado que você recebeu
ssh -i $CERTDIR $USERNAME@150.165.15.73
```

TODO: completar comando ssh com o ip externo da VM e a porta definitiva.

### Criar a identidade do produtor

```bash
# Entrar no container do spire-server para acessar a cli
kubectl exec -it -n spire $(kubectl get pods -n spire -o=jsonpath='{.items[0].metadata.name}' \
    -l app=spire-server)  /bin/sh

export USERNAME=<user> # substitua <user> pelo nome de usuário que você recebeu

bin/spire-server entry create \
    -parentID spiffe://lsd.ufcg.edu.br/agente-k8s \
    -selector k8s:ns:$USERNAME \
    -selector k8s:container-name:produtor-kafka \
    -spiffeID spiffe://lsd.ufcg.edu.br/produtor/$USERNAME
exit
```

### Fazer deploy do produtor

```bash
# Aplica o deployment
kubectl apply -f produtor-deployment.yaml
# Verificar stado do pod
kubectl get pods
# Verificar logs da aplicação
kubectl logs $(kubectl get pods -o=jsonpath='{.items[0].metadata.name}' \
    -l app=produtor-kafka) -f
```

### Criar sessão do consumidor SCONE

```bash
# Atestar CAS
scone cas attest 5-4-0.scone-cas.cf  -C -G --only_for_testing-trust-any --only_for_testing-debug --only_for_testing-ignore-signer
# Criar namespace e sessão no CAS
scone session create scone-namespace.yaml
scone session create scone-session.yaml > session-hash.txt
```

### Criar identidade do consumidor

```bash
# Copie o conteúdo do arquivo session-hash.txt
cat session-hash.txt && echo
kubectl exec -it -n spire $(kubectl get pods -n spire -o=jsonpath='{.items[0].metadata.name}' \
    -l app=spire-server)  /bin/sh
export USERNAME=<user> # substitua <user> pelo nome de usuário que você recebeu
export SESSION_HASH=<hash> # substitua <hash> pelo conteúdo do arquivo session-hash.txt
export AGENTE_ID=spiffe://lsd.ufcg.edu.br/agente-scone
./bin/spire-server entry create -parentID $AGENTE_ID \
        -spiffeID spiffe://lsd.ufcg.edu.br/consumidor/$USERNAME \
        -selector svidstore:type:scone_cas_secretsmanager \
        -selector cas_session_hash:$SESSION_HASH \
        -selector cas_session_name:$USERNAME/svid-session
exit
```

### Fazer deploy do consumidor

```bash
# Aplica o deployment
kubectl apply -f consumidor-deployment.yaml
# Verificar stado do pod
kubectl get pods
# Verificar logs da aplicação
kubectl logs $(kubectl get pods -o=jsonpath='{.items[0].metadata.name}' \
    -l app=consumidor-kafka) -f
```
