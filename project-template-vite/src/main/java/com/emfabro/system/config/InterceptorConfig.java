package com.emfabro.system.config;

import com.emfabro.system.interceptor.ForceForward;
import com.emfabro.system.interceptor.PrivInterceptor;
import com.emfabro.system.service.Profile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import static com.emfabro.global.constant.WebValues.PREFIX_PRIV;
import static com.emfabro.global.constant.WebValues.PREFIX_PUB;
import static com.emfabro.system.constant.SystemValues.PROFILE_DEV;
import static com.emfabro.system.constant.SystemValues.PROFILE_LOCAL;

@Configuration
public class InterceptorConfig implements WebMvcConfigurer {

    @Autowired
    private ForceForward forceForward;

    @Autowired
    private Profile profile;

    @Autowired
    private PrivInterceptor privInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(privInterceptor)
                .order(5)
                .addPathPatterns(PREFIX_PRIV + "/**");

        registry.addInterceptor(forceForward)
                .order(10)
                .addPathPatterns("/{spring:\\w+}")
                .excludePathPatterns(getForwardExcludes());
    }

    /**
     * 避免下列網址被強制轉頁
     *
     * @return String[]
     */
    private String[] getForwardExcludes() {
        String excludes = PREFIX_PRIV + "/**," + PREFIX_PUB + "/**";

        if (profile.hasProfile(PROFILE_DEV) || profile.hasProfile(PROFILE_LOCAL)) {
            excludes += ",/swagger-resources/**,/v2/api-docs/**,/swagger.json,/swagger-ui.html,/webjars/**";
        }

        return excludes.split(",");
    }
}
