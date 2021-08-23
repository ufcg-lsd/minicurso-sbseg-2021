#!/usr/bin/env bash

cat >> /server-helper.conf <<EOF
agentAddress = "$AGENT_SOCKET"
cmd = "/entrypoint/helper_cmd.sh"
certDir = "/store"
renewSignal = ""
svidFileName = "kafka-server-cert.pem"
svidKeyFileName = "kafka-server-key.pem"
svidBundleFileName = "ca-cert.pem"
addIntermediatesToBundle = false
EOF
