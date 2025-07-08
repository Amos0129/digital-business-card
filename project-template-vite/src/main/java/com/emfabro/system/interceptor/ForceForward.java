package com.emfabro.system.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * 將符合條件的網址強制轉為 /
 * 這是為了避免網址會帶上 #
 */
@Component
public class ForceForward implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {

        request.getRequestDispatcher("/").forward(request, response);

        return false;
    }
}
