#!/bin/bash

function log {
  sleep 1
  echo $1
}

sslDir="/tmp/kafka-ssl-demo"
validity=365
caPassword=1234
serverKeystorePassword=123456
serverKeyPassword=123456
clientKeystorePassword=123456

# Users
rootUserKeystorePassword=123456
rootUserKeyPassword=123456

producerUserKeystorePassword=123456
producerUserKeyPassword=123456

consumerUserKeystorePassword=123456
consumerUserKeyPassword=123456


log "SSL DIR:$sslDir"
log "Certificate Validity (in days):$validity"

log  "Creating fresh directory for SSL Files..."
rm -fr $sslDir
mkdir -p $sslDir

log "Go to dir $sslDir..."
cd $sslDir


log "Creating Certificate Authority (CA)..."
openssl req \
  -new \
  -x509 \
  -days $validity \
  -keyout ca.key \
  -out ca.crt \
  -subj "/C=GB/L=London/CN=Certificate Authority" \
  -passout pass:$caPassword

log "Printing certificate contents..."
openssl x509 -text -noout -in ca.crt

log  "Generating SSL Keys and Certificate for Kafka Brokers..."
keytool \
  -genkey \
  -keystore server.keystore \
  -alias localhost \
  -dname CN=localhost \
  -keyalg RSA \
  -validity $validity \
  -ext san=dns:localhost \
  -storepass $serverKeystorePassword \
  -keypass $serverKeyPassword

log "Printing contents of the keystore..."
keytool -list -v -keystore server.keystore -storepass $serverKeystorePassword

log "Signing Broker Certificate (Using CA)..."
log "Export the server certificate from server.keystore"

keytool \
  -certreq \
  -keystore server.keystore \
  -alias localhost \
  -file server.unsigned.crt \
  -storepass $serverKeystorePassword \
  -noprompt

log "Sign the certificate signing request (server.unsigned.crt) with the root CA."
openssl x509 \
  -req \
  -CA ca.crt \
  -CAkey ca.key \
  -in server.unsigned.crt \
  -out server.crt \
  -days $validity \
  -CAcreateserial \
  -passin pass:$caPassword


log "Import Certificates to Broker Keystore"
log "Import the certificate of the CA into the broker keystore."

keytool \
  -import \
  -file ca.crt \
  -keystore server.keystore \
  -alias ca \
  -storepass $serverKeystorePassword \
  -noprompt

log "Import the signed certificate into the broker keystore."
keytool \
  -import \
  -file server.crt \
  -keystore server.keystore \
  -alias localhost \
  -storepass $serverKeystorePassword \
  -noprompt

log "Use keytool to print out the certificates in the broker keystore."
keytool -list -v -keystore server.keystore -storepass $serverKeystorePassword

# # Configure SSL on Kafka Broker - Properties file
##listeners=PLAINTEXT://:9092,SSL://:9093
##ssl.keystore.location=/tmp/kafka-ssl-demo/server.keystore
##ssl.keystore.password=123456
##ssl.key.password=123456

## Start the broker(s).
#./bin/kafka-server-start.sh config/server-ssl.properties
#
##export KAFKA_OPTS=-Djavax.net.debug=all
#
##Verify the SSL configuration of the broker.
#openssl s_client -connect localhost:9093

##Use the client tool with -CAfile option to trust the CA certificate.
#openssl s_client -connect localhost:9093 -CAfile /tmp/kafka-ssl-demo/ca.crt

log "Import CA Certificate to Client Truststore"
keytool \
  -import \
  -file ca.crt \
  -keystore client.truststore \
  -alias ca \
  -storepass $clientKeystorePassword \
  -noprompt

log "Use keytool to print out the certificates in the client keystore."
keytool -list -v -keystore client.truststore -storepass $clientKeystorePassword

## Configure SSL for Kafka Clients - client-ssl.properties
##security.protocol=SSL
##ssl.truststore.location=/tmp/kafka-ssl-demo/client.truststore
##ssl.truststore.password=123456
#
## Use kafka-console-producer.sh utility to send records to Kafka brokers over SSL:
#bin/kafka-console-producer.sh \
#  --broker-list :9093 \
#  --topic ssl \
#  --producer.config config/client-ssl.properties
#
## Generate Certificate for Client Authentication
#keytool \
#  -genkey \
#  -keystore fps.keystore \
#  -alias fps \
#  -dname CN=fps \
#  -keyalg RSA \
#  -validity 365 \
#  -storepass 123456
#
## Use keytool to print out the certificates in the client keystore.
#keytool -list -v -keystore fps.keystore -storepass 123456
#
## Sign Client Certificate (Using CA)
#keytool \
#  -certreq \
#  -keystore fps.keystore \
#  -alias fps \
#  -file fps.unsigned.crt \
#  -storepass 123456
#
#openssl x509 \
#  -req \
#  -CA ca.crt \
#  -CAkey ca.key \
#  -in fps.unsigned.crt \
#  -out fps.crt \
#  -days 365 \
#  -CAcreateserial \
#  -passin pass:1234
#
## Import Certificates to Client Keystore
### Import the certificate of the CA into the client keystore.
#keytool \
#  -import \
#  -file ca.crt \
#  -keystore fps.keystore \
#  -alias ca \
#  -storepass 123456 \
#  -noprompt
#
### Import the signed certificate into the client keystore.
#keytool \
#  -import \
#  -file fps.crt \
#  -keystore fps.keystore \
#  -alias fps \
#  -storepass 123456 \
#  -noprompt
#
## Use keytool to print out the certificates in the client keystore.
#keytool -list -v -keystore fps.keystore -storepass 123456
#

log "Configure Broker to Trust Certificate Authority"

keytool \
  -import \
  -file ca.crt \
  -keystore server.truststore \
  -alias ca \
  -storepass $serverKeystorePassword \
  -noprompt

## Enable SSL for Inter-Broker Communication
##security.inter.broker.protocol=SSL
##ssl.truststore.location=/tmp/kafka-ssl-demo/server.truststore
##ssl.truststore.password=123456


log "Configure SSL for Kafka Clients"
log "Create User CN=root -  a user with all topic operations allowed"
log "Generate the keys and certificate of the user."
keytool \
  -genkey \
  -keystore root.keystore \
  -alias root \
  -dname CN=root \
  -keyalg RSA \
  -validity $validity \
  -storepass $rootUserKeystorePassword \
  -keypass $rootUserKeyPassword

log "Export the certificate of the user from the keystore."
keytool \
  -certreq \
  -keystore root.keystore \
  -alias root \
  -file root.unsigned.crt \
  -storepass $rootUserKeystorePassword

log "Sign the certificate signing request with the root CA."
openssl x509 \
  -req \
  -CA ca.crt \
  -CAkey ca.key \
  -in root.unsigned.crt \
  -out root.crt \
  -days $validity \
  -CAcreateserial \
  -passin pass:$caPassword

log "Import the certificate of the CA into the root user keystore."
keytool \
  -importcert \
  -file ca.crt \
  -alias ca \
  -keystore root.keystore \
  -storepass $rootUserKeystorePassword \
  -noprompt

log "Import the signed certificate into the root user keystore. Make sure to use the same -alias as you used earlier."
keytool \
  -importcert \
  -file root.crt \
  -alias root \
  -keystore root.keystore \
  -storepass $rootUserKeystorePassword


## Define Super Users - config/server-ssl.properties
## super.users=User:CN=localhost;User:CN=root
#
## (Optional) Allow Everyone If No ACL Found - config/server-ssl.properties
## allow.everyone.if.no.acl.found=true
#
## List ACLs - root.properties
##security.protocol=SSL
##ssl.truststore.location=/tmp/kafka-ssl-demo/client.truststore
##ssl.truststore.password=123456
##ssl.keystore.location=/tmp/kafka-ssl-demo/root.keystore
##ssl.keystore.password=123456
##ssl.key.password=123456
#
## Use --command-config option to specify the SSL configuration.
#bin/kafka-acls.sh \
#  --bootstrap-server :9093 \
#  --list \
#  --command-config config/root.properties
#
#

log "Create User CN=producer"
keytool \
  -genkey \
  -keystore producer.keystore \
  -alias producer \
  -dname CN=producer \
  -keyalg RSA \
  -validity $validity \
  -storepass $producerUserKeystorePassword \
  -keypass $producerUserKeyPassword

keytool \
  -certreq \
  -keystore producer.keystore \
  -alias producer \
  -file producer.unsigned.crt \
  -storepass $producerUserKeystorePassword

openssl x509 \
  -req \
  -CA ca.crt \
  -CAkey ca.key \
  -in producer.unsigned.crt \
  -out producer.crt \
  -days $validity \
  -CAcreateserial \
  -passin pass:$caPassword

keytool \
  -import \
  -file ca.crt \
  -keystore producer.keystore \
  -alias ca \
  -storepass $producerUserKeystorePassword \
  -noprompt

keytool \
  -import \
  -file producer.crt \
  -keystore producer.keystore \
  -alias producer \
  -storepass $producerUserKeystorePassword \
  -noprompt

log "Create User CN=consumer"
keytool \
  -genkey \
  -keystore consumer.keystore \
  -alias consumer \
  -dname CN=consumer \
  -keyalg RSA \
  -validity $validity \
  -storepass $consumerUserKeystorePassword \
  -keypass $consumerUserKeyPassword

keytool \
  -certreq \
  -keystore consumer.keystore \
  -alias consumer \
  -file consumer.unsigned.crt \
  -storepass $consumerUserKeystorePassword

openssl x509 \
  -req \
  -CA ca.crt \
  -CAkey ca.key \
  -in consumer.unsigned.crt \
  -out consumer.crt \
  -days $validity \
  -CAcreateserial \
  -passin pass:$caPassword

keytool \
  -import \
  -file ca.crt \
  -alias ca \
  -keystore consumer.keystore \
  -storepass $consumerUserKeystorePassword \
  -noprompt

keytool \
  -import \
  -file consumer.crt \
  -alias consumer \
  -keystore consumer.keystore \
  -storepass $consumerUserKeystorePassword