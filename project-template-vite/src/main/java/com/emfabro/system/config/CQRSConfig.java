package com.emfabro.system.config;

import javax.sql.DataSource;

import jakarta.persistence.EntityManagerFactory;
import org.apache.ibatis.io.VFS;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.boot.autoconfigure.SpringBootVFS;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.orm.jpa.EntityManagerFactoryBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.transaction.PlatformTransactionManager;

import static com.emfabro.system.constant.SystemValues.BASE_DOMAIN;
import static com.emfabro.system.constant.SystemValues.BASE_TYPE_HANDLER;
import static com.emfabro.system.constant.SystemValues.CQRS_SYMBOL;
import static com.emfabro.system.constant.SystemValues.ENTITY_MANAGER_FACTORY;
import static com.emfabro.system.constant.SystemValues.TRANSACTION_MANAGER;

public abstract class CQRSConfig {

    @Primary
    @Bean
    public abstract DataSource command();


    // FIXME: 要動態配置資料來源時請在這裡加入, 並參考 AbstractRoutingDataSource
    @Bean
    public DataSource routingDataSources() {
        return command();
    }

    @Primary
    @Bean
    public SqlSessionFactoryBean sqlSessionFactory() {
        VFS.addImplClass(SpringBootVFS.class);
        SqlSessionFactoryBean sessionFactoryBean = new SqlSessionFactoryBean();
        sessionFactoryBean.setDataSource(routingDataSources());
        sessionFactoryBean.setTypeAliasesPackage(BASE_TYPE_HANDLER);
        sessionFactoryBean.setTypeHandlersPackage(BASE_TYPE_HANDLER);

        return sessionFactoryBean;
    }

    @Primary
    @Bean(ENTITY_MANAGER_FACTORY)
    public LocalContainerEntityManagerFactoryBean commandEntityManagerFactory(
            EntityManagerFactoryBuilder builder) {
        return builder.dataSource(routingDataSources())
                      .packages(BASE_DOMAIN)
                      .persistenceUnit(CQRS_SYMBOL)
                      .build();
    }

    @Primary
    @Bean(TRANSACTION_MANAGER)
    public PlatformTransactionManager transactionManager(@Qualifier(ENTITY_MANAGER_FACTORY)
    EntityManagerFactory managerFactory) {
        return new JpaTransactionManager(managerFactory);
    }

    public static class JndiHolder {
        private String jndiName;

        public String getJndiName() {
            return jndiName;
        }

        public void setJndiName(String jndiName) {
            this.jndiName = jndiName;
        }
    }

}
