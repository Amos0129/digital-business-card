package com.emfabro.system.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;


@PropertySource("classpath:application.properties")
@Component
public class CustomProperties {

    @Autowired
    private Environment env;

    public String getAppVersion() {
        return env.getProperty("custom.version");
    }

}
