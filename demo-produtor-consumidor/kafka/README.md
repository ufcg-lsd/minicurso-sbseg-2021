# Kafka: IDs, tópicos, e ACL

```bash
# SPIFFE ID
bin/spire-server entry create -parentID spiffe://lsd.ufcg.edu.br/agente-kafka -spiffeID spiffe://lsd.ufcg.edu.br/kafka -selector unix:user:root -dns kafka

# Criação de tópicos
bin/kafka-topics.sh --create   --zookeeper localhost:2181   --topic test --partitions 1 --replication-factor 1

# Regra ACL para o produtor
docker exec kafka-broker   /bin/kafka-acls.sh   --authorizer-properties zookeeper.connect=kafka-zookeeper:2181   --cluster '*' --operation 'All'  --group '*' --topic 'test'   --add --allow-principal 'SPIFFE:spiffe://lsd.ufcg.edu.br/produtor' --allow-host '*'

# Regra ACL para o consumidor
docker exec kafka-broker   /bin/kafka-acls.sh   --authorizer-properties zookeeper.connect=kafka-zookeeper:2181   --cluster '*' --operation 'All'  --group '*' --topic 'test'   --add --allow-principal 'SPIFFE:spiffe://lsd.ufcg.edu.br/consumidor' --allow-host '*'
```