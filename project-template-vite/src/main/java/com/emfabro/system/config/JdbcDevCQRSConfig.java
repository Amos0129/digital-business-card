package com.emfabro.system.config;

import javax.sql.DataSource;

import org.apache.tomcat.dbcp.dbcp2.BasicDataSource;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import static com.emfabro.system.constant.SystemValues.PREFIX_COMMAND;
import static com.emfabro.system.constant.SystemValues.PROFILE_DEV;
import static com.emfabro.system.constant.SystemValues.PROFILE_LOCAL;

@Profile({PROFILE_DEV, PROFILE_LOCAL})
@Configuration
@EnableTransactionManagement
public class JdbcDevCQRSConfig extends CQRSConfig {

    @Primary
    @Bean
    @ConfigurationProperties(PREFIX_COMMAND)
    public DataSourceProperties commandProperties() {
        return new DataSourceProperties();
    }

    @Override
    public DataSource command() {
        return commandProperties().initializeDataSourceBuilder()
                                  .type(BasicDataSource.class)
                                  .build();
    }
}
