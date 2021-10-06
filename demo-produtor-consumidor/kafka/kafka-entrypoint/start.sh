#!/usr/bin/env bash

set -ex

bash /entrypoint/gen-server-conf.sh
bash /entrypoint/gen-helper-conf.sh

nohup /spiffe-helper/spiffe-helper -config /server-helper.conf > /spiffe-helper.log &

exec bin/kafka-server-start.sh config/server.properties
