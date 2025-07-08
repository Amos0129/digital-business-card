package com.emfabro.system.api;

import com.emfabro.system.config.CustomProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static com.emfabro.global.constant.WebValues.PREFIX_PUB;

@RestController
@RequestMapping(PREFIX_PUB)
public class VersionEcho {

    @Autowired
    private CustomProperties customProperties;

    @GetMapping("/version")
    public String apiVersion() {
        return customProperties.getAppVersion();
    }

}
