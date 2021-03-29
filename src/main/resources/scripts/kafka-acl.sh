#!/bin/bash

function log {
  sleep 1
  echo $1
}

KAFKA_HOME=/Users/sibyg/apps/kafka

echo "KAFKA_HOME_DIR=$KAFKA_HOME"

log "Restrict Topic Operations Write for CN=produce"
$KAFKA_HOME/bin/kafka-acls.sh \
  --bootstrap-server :9093 \
  --add \
  --allow-principal User:CN=producer \
  --operation Write \
  --topic '*' \
  --command-config config/root.properties

log "List the ACLs using kafka-acls utility."
$KAFKA_HOME/bin/kafka-acls.sh \
  --bootstrap-server :9093 \
  --list \
  --command-config $KAFKA_HOME/config/root.properties

log "Restrict Topic Operations Read for CN=consumer"
$KAFKA_HOME/bin/kafka-acls.sh \
  --bootstrap-server :9093 \
  --add \
  --allow-principal User:CN=consumer \
  --operation Read \
  --topic '*' \
  --command-config $KAFKA_HOME/config/root.properties

log "Restrict Topic Operations Read for CN=consumer in Group consumer-group"
$KAFKA_HOME/bin/kafka-acls.sh \
  --bootstrap-server localhost:9093 \
  --command-config $KAFKA_HOME/config/root.properties \
  --add --allow-principal User:CN=consumer --operation Read --group consumer-group

log "List the ACLs using kafka-acls utility."
$KAFKA_HOME/bin/kafka-acls.sh \
  --bootstrap-server :9093 \
  --list \
  --command-config $KAFKA_HOME/config/root.properties


log "SASL-PLAINTEXT BASED ACLs"
bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:fps --operation Write --operation Create --topic fps+

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:acs --operation Write --operation Create --topic acs*

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:fps --operation Read --group fps-group

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:acs --operation Read --group acs-group

log "Wildcard based topic and group name"
bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:fps --producer --topic fps- --resource-pattern-type prefixed

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:acs --producer --topic acs- --resource-pattern-type prefixed

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:fps --operation Read --operation Describe --topic fps- --resource-pattern-type prefixed

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:acs --operation Read --operation Describe --topic acs- --resource-pattern-type prefixed

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties  --add --allow-principal User:fps --operation Read --group '*'

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties  --add --allow-principal User:acs --operation Read --group '*'


bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic acs-topic-1 --producer.config config/sasl-acs.properties

bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic fps-topic-1 --producer.config config/sasl-acs.properties


bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:fps --operation Describe --topic *

bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config ./config/sasl-admin.properties --add --allow-principal User:acs --operation Describe --topic *

bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic fps-topic-1 --group fps-group --consumer.config config/sasl-fps.properties --from-beginning

bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic acs-topic-1 --group acs-group --consumer.config config/sasl-acs.properties --from-beginning