package com.emfabro.system.config;

import java.util.List;

import com.emfabro.global.utils.JwtUtil;
import com.emfabro.system.filter.JwtFilter;
import com.emfabro.system.service.Profile;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.header.writers.XXssProtectionHeaderWriter;
import org.springframework.web.cors.CorsConfiguration;

import static com.emfabro.system.constant.SystemValues.PROFILE_DEV;
import static com.emfabro.system.constant.SystemValues.PROFILE_LOCAL;

@Configuration
@EnableWebSecurity
@Slf4j
public class SecurityConfig {

    @Autowired
    private Profile profile;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return isDev(http)
                .headers(config ->
                        config.defaultsDisabled()
                                .cacheControl(Customizer.withDefaults())
                                .contentTypeOptions(Customizer.withDefaults())
                                .frameOptions(frameOptionsConfig -> frameOptionsConfig.sameOrigin()
                                        .xssProtection(xXssConfig ->
                                                xXssConfig.headerValue(XXssProtectionHeaderWriter.HeaderValue.ENABLED))
                                )
                ).build();
    }

    /**
     * cors.addAllowedOrigin("XXXX")
     * 請依據開發前端 test server 設定, 例如 http://localhost:5566
     *
     * @return HttpSecurity
     */
    public HttpSecurity isDev(HttpSecurity http) throws Exception {
        if (profile.hasProfiles(PROFILE_DEV, PROFILE_LOCAL)) {
            CorsConfiguration corsConfig = new CorsConfiguration();

            corsConfig.setAllowedOrigins(List.of(
                    "http://localhost:3000",
                    "http://localhost:12912"
            ));
            corsConfig.addAllowedMethod("*");
            corsConfig.addAllowedHeader("*");
            corsConfig.setAllowCredentials(true);

            return http.cors(config -> config.configurationSource(request -> corsConfig))
                    .csrf(AbstractHttpConfigurer::disable);
        } else {
            return http.cors(AbstractHttpConfigurer::disable);
        }
    }

    @Bean
    public FilterRegistrationBean<JwtFilter> jwtFilter(JwtUtil jwtUtil) {
        FilterRegistrationBean<JwtFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new JwtFilter(jwtUtil));
        registrationBean.addUrlPatterns("/api/*", "/api/*/*", "/api/*/*/*", "/api/*/*/*/*");
        registrationBean.setOrder(1);
        return registrationBean;
    }

    @Bean
    public JwtFilter jwtTokenFilter(JwtUtil jwtUtil) {
        return new JwtFilter(jwtUtil);
    }

}
