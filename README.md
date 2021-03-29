# kafka-security-demo

## Prerequisites
<KAFKA_HOME_DIR> env variable must be set.

## Introduction
This project contains scripts, properties used for SSL, SASL-PLAINTEXT based Kafka Authentication and Authorisation.
It covers, 
    Inter Broker Communication
    Broker-ZooKeeper Communication
    Client Broker Communication
    
## gen-certs.sh 
is used to generate all SSL certs/keystores.

## kafka-acl.sh
is used to perform ACL operations on Kafka

## ssl-server.properties
Working ssl configuration. You need to replace variables with actual values 