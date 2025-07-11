package com.emfabro.system.config;
import com.emfabro.system.interceptor.ForceForward;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.emfabro.system.interceptor.ForceForward;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
public class WebConfig implements WebMvcConfigurer {

    private final ForceForward forceForward;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(forceForward)
                .addPathPatterns("/**")
                .excludePathPatterns("/api/**");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/static/avatars/**")
                .addResourceLocations("file:C:/DigitalBusinessCard/project-template-vite/uploads/avatars/");
    }
}
