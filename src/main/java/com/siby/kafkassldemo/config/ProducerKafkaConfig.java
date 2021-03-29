package com.siby.kafkassldemo.config;

import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;

import java.util.HashMap;
import java.util.Map;

import static java.lang.String.format;

@Configuration
public class ProducerKafkaConfig {

    @Value(value = "${spring.kafka.bootstrapAddress}")
    private String bootstrapAddress;

    @Value(value = "${spring.kafka.ssl.enabled}")
    private Boolean sslEnabled;

    @Value(value = "${spring.kafka.ssl.producer.truststore.location}")
    private String truststoreLocation;

    @Value(value = "${spring.kafka.ssl.producer.truststore.password}")
    private String trustStorePassword;

    @Value(value = "${spring.kafka.ssl.producer.keystore.location}")
    private String keyStoreLocation;

    @Value(value = "${spring.kafka.ssl.producer.keystore.password}")
    private String keyStorePassword;

    @Value(value = "${spring.kafka.ssl.producer.key.password}")
    private String keyPassword;

    @Value(value = "${spring.kafka.sasl.enabled}")
    private Boolean saslEnabled;

    @Value(value = "${spring.kafka.sasl.producer.username}")
    private String saslProducerUsername;

    @Value(value = "${spring.kafka.sasl.producer.password}")
    private String saslProducerPassword;


    @Bean
    public ProducerFactory<String, String> producerFactory() {
        Map<String, Object> props = new HashMap<>();
        props.put(
                ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,
                bootstrapAddress);
        props.put(
                ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,
                StringSerializer.class);
        props.put(
                ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
                StringSerializer.class);

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
                    "required username='%s'   password='%s';", saslProducerUsername, saslProducerPassword));
            props.put("security.protocol", "SASL_PLAINTEXT");
        }


        System.out.println("PRODUCER-PROPERTIES:" + props);

        return new DefaultKafkaProducerFactory<>(props);
    }

    @Bean
    public KafkaTemplate<String, String> kafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }
}