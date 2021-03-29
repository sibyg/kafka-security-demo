# Send Messages
##producer.properties
#security.protocol=SSL
#ssl.truststore.location=/tmp/kafka-ssl-demo/client.truststore
#ssl.truststore.password=123456
#ssl.keystore.location=/tmp/kafka-ssl-demo/producer.keystore
#ssl.keystore.password=123456
#ssl.key.password=123456

##send script
bin/kafka-console-producer.sh \
  --broker-list :9093 \
  --topic ssl \
  --producer.config config/producer.properties

# Consume Messages
##consumer.properties
#security.protocol=SSL
#ssl.truststore.location=/tmp/kafka-ssl-demo/client.truststore
#ssl.truststore.password=123456
#ssl.keystore.location=/tmp/kafka-ssl-demo/consumer.keystore
#ssl.keystore.password=123456
#ssl.key.password=123456

## consumer script
bin/kafka-console-consumer.sh \
  --bootstrap-server :9093 \
  --topic ssl \
  --group consumer-group
  --consumer.config config/consumer.properties