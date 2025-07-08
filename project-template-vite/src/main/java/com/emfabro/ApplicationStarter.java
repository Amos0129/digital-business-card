package com.emfabro;

import java.security.Security;

import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.WebApplicationInitializer;

import static com.emfabro.system.constant.SystemValues.BASE_COMPONENT;
import static com.emfabro.system.constant.SystemValues.BASE_DAO;

@EnableScheduling
@SpringBootApplication(scanBasePackages = BASE_COMPONENT)
@EnableJpaRepositories(basePackages = BASE_DAO, considerNestedRepositories = true)
public class ApplicationStarter extends SpringBootServletInitializer implements WebApplicationInitializer {

    public static void main(String[] args) {
        Security.addProvider(new BouncyCastleProvider());

        SpringApplication.run(ApplicationStarter.class, args);
    }
}
