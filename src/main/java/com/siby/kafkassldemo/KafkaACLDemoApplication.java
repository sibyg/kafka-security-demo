package com.siby.kafkassldemo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableAutoConfiguration
public class KafkaACLDemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(KafkaACLDemoApplication.class, args);
	}

}
