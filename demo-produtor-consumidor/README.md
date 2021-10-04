# Demo produtor-consumidor

## Demo coletiva

Nesse momento, você já deve ter recebido dados de acesso à máquina virtual com todas as ferramentas necessárias para excutar a demonstração.

Faça login na máquina via SSH. Assumindo um sistema operacional UNIX, o seguinte comando deve fazer isso.

```bash
export USERNAME=<user> # substitua <user> pelo nome de usuário que você recebeu
export CERTDIR=<cert-dir> # substitua <cert-dir> pelo caminho para o certificado que você recebeu
ssh -i $CERTDIR $USERNAME@
```

TODO: completar comando ssh com o ip externo da VM e a porta definitiva.

### Criar a identidade do produtor

```bash
kubectl exec -it -n spire $(kubectl get pods -n spire -o=jsonpath='{.items[0].metadata.name}' \
    -l app=spire-server)  /bin/sh

export USERNAME=<user> # substitua <user> pelo nome de usuário que você recebeu

bin/spire-server entry create \
    -parentID spiffe://lsd.ufcg.edu.br/agente-scone \
    -selector k8s:ns:$USERNAME \
    -selector k8s:container-name:produtor-kafka \
    -spiffeID spiffe://lsd.ufcg.edu.br/produtor/$USERNAME
exit
```


TODO:
- (Em progresso) Cadastra identidade do produtor
- Cria sessão do consumidor
- Cadastra identidade do consumidor
- Implanta produtor
- Implanta consumidor

## Reproduza você mesmo

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

Implantar agente SPIRE:

```bash
kubectl apply -f agent-account.yaml
kubectl apply -f agent-cluster-role.yaml
# Agente regular.
kubectl apply -f agent-configmap.yaml
kubectl apply -f agent-daemonset.yaml
# Agente com plugin SVIDStore SCONE
kubectl apply -f agent-scone-configmap.yaml
kubectl apply -f agent-scone-deployment.yaml
```


Agente SPIRE local:

```bash
git clone https://github.com/ufcg-lsd/spire -b scone_svid_store_plugin
cd spire
go build ./cmd/spire-agent
```


Criando joinToken para o Agente local e uma identidade para o kafka.

```bash
kubectl exec -it -n spire spire-server sh
# Dentro do container

bin/spire-server token generate -spiffeID spiffe://lsd.ufcg.edu.br/agente-kafka
# Copie o token para usá-lo no próximo passo
bin/spire-server entry create -parentID spiffe://lsd.ufcg.edu.br/agente-kafka -spiffeID spiffe://lsd.ufcg.edu.br/kafka -selector unix:user:root -dns kafka
```


Executar o Agente local.

```bash
export TOKEN=
./spire-agent run -joinToken $TOKEN  -config agent.conf
```


Executar o kafka.

```bash
cd kafka
docker-compose up
```


Registrar o produtor.

```bash
export AGENTE_ID=spiffe://lsd.ufcg.edu.br/agente-scone
bin/spire-server entry create \
    -parentID $AGENTE_ID \
    -spiffeID spiffe://lsd.ufcg.edu.br/produtor \
    -selector k8s:container-name:produtor-kafka \
    -selector k8s:ns:default
```


Criar uma sessão SCONE para o consumidor e registrar uma entrada SPIRE para o consumidor.

```bash
# Use um container SCONE CLI para atestar o cas e postar a sessão em ./consumidor/scone-session.yaml
# Registrar entrada SPIRE
export SESSION_HASH=a91ed304958530306f0cab3a2977cbd84e139352ed3cd2002b6145ee4c4d722f
export SESSION_NAME=svid-session
export AGENTE_ID=spiffe://lsd.ufcg.edu.br/agente-scone

./bin/spire-server entry create -parentID $AGENTE_ID \
        -spiffeID spiffe://lsd.ufcg.edu.br/consumidor \
        -selector svidstore:type:scone_cas_secretsmanager \
        -selector cas_session_hash:$SESSION_HASH \
        -selector cas_session_name:$SESSION_NAME
```


Implantação do produtor e do consumidor.

```bash
kubectl apply -f produtor/deployment.yaml
kubectl apply -f consumidor/deployment.yaml
```

Liberar recursos.

```bash
minikube delete
```