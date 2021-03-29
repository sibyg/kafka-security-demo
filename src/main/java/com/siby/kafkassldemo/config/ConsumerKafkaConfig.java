package com.siby.kafkassldemo.config;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;

import java.util.HashMap;
import java.util.Map;

import static java.lang.String.format;

@EnableKafka
@Configuration
public class ConsumerKafkaConfig {

    @Value(value = "${spring.kafka.bootstrapAddress}")
    private String bootstrapAddress;

    @Value(value = "${spring.kafka.consumer.group-id}")
    private String groupId;

    @Value(value = "${spring.kafka.ssl.enabled}")
    private Boolean sslEnabled;

    @Value(value = "${spring.kafka.ssl.consumer.truststore.location}")
    private String truststoreLocation;

    @Value(value = "${spring.kafka.ssl.consumer.truststore.password}")
    private String trustStorePassword;

    @Value(value = "${spring.kafka.ssl.consumer.keystore.location}")
    private String keyStoreLocation;

    @Value(value = "${spring.kafka.ssl.consumer.keystore.password}")
    private String keyStorePassword;

    @Value(value = "${spring.kafka.ssl.consumer.key.password}")
    private String keyPassword;

    @Value(value = "${spring.kafka.sasl.enabled}")
    private Boolean saslEnabled;

    @Value(value = "${spring.kafka.sasl.consumer.username}")
    private String saslConsumerUsername;

    @Value(value = "${spring.kafka.sasl.consumer.password}")
    private String saslConsumerPassword;

    @Bean
    public ConsumerFactory<String, String> consumerFactory() {
        Map<String, Object> props = new HashMap<>();
        props.put(
                ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,
                bootstrapAddress);
        props.put(
                ConsumerConfig.GROUP_ID_CONFIG,
                groupId);
        props.put(
                ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
                StringDeserializer.class);
        props.put(
                ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
                StringDeserializer.class);

        if (sslEnabled) {
            props.put("security.protocol", "SSL");
            props.put("ssl.truststore.location", truststoreLocation);
            props.put("ssl.truststore.password", trustStorePassword);

            props.put("ssl.keystore.location", keyStoreLocation);
            props.put("ssl.keystore.password", keyStorePassword);
            props.put("ssl.key.password", keyPassword);
        }

        if (saslEnabled) {
            props.put("sasl.mechanism", "PLAIN");
            props.put("sasl.jaas.config", format("org.apache.kafka.common.security.plain.PlainLoginModule   " +
                    "required username='%s'   password='%s';", saslConsumerUsername, saslConsumerPassword));
            props.put("security.protocol", "SASL_PLAINTEXT");
        }


        return new DefaultKafkaConsumerFactory<>(props);
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, String>
    kafkaListenerContainerFactory() {

        ConcurrentKafkaListenerContainerFactory<String, String> factory =
                new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(consumerFactory());
        return factory;
    }
}