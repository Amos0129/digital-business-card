package com.emfabro.system.config;

import javax.sql.DataSource;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.datasource.lookup.JndiDataSourceLookup;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import static com.emfabro.system.constant.SystemValues.PREFIX_COMMAND;
import static com.emfabro.system.constant.SystemValues.PROFILE_PROD;
import static com.emfabro.system.constant.SystemValues.PROFILE_TEST;
import static com.emfabro.system.constant.SystemValues.PROFILE_UAT;

@Profile({PROFILE_TEST, PROFILE_UAT, PROFILE_PROD})
@Configuration
@EnableTransactionManagement
public class JndiCQRSConfig extends CQRSConfig {

    @Primary
    @Bean
    @ConfigurationProperties(PREFIX_COMMAND)
    public CQRSConfig.JndiHolder commandJndi() {
        return new JndiHolder();
    }

    @Override
    public DataSource command() {
        JndiDataSourceLookup lookup = new JndiDataSourceLookup();
        return lookup.getDataSource(commandJndi().getJndiName());
    }
}
