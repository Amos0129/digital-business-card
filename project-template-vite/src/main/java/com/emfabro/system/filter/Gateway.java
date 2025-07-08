package com.emfabro.system.filter;

import java.io.IOException;

import com.emfabro.system.filter.wrapper.CustomWrapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Slf4j
@Component
public class Gateway extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        CustomWrapper wrapper = new CustomWrapper(request, response);

        filterChain.doFilter(wrapper.customReq, wrapper.customResp);
    }
}
