#!/usr/bin/env bash

cd /store/

openssl pkcs8 \
  -in kafka-server-key.pem \
  -passout "pass:123456" \
  -topk8 -v1 PBE-SHA1-3DES \
  -out kafka-server-key-pbes1.pem
cat kafka-server-key-pbes1.pem kafka-server-cert.pem > kafka-server-pair.pem

/bin/kafka-configs.sh \
  --bootstrap-server ${HOSTNAME}:9092 \
  --command-config /config/server_ssl.properties \
  --entity-type brokers \
  --entity-name 0 --alter \
  --add-config security.protocol=SSL
