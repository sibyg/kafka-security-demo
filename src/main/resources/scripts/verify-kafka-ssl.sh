#!/bin/bash

function log {
  sleep 1
  echo $1
}

kafkaHostName=localhost
kafkaSSLPort=9093

log "Verify the SSL configuration of the broker."
openssl s_client -connect $kafkaHostName:$kafkaSSLPort


log "Use the client tool with -CAfile option to trust the CA certificate."
openssl s_client -connect $kafkaHostName:$kafkaSSLPort -CAfile /tmp/kafka-ssl-demo/ca.crt