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

        String path = request.getRequestURI();

        System.out.println("➡ ForceForward Interceptor triggered: " + path + " (" + request.getMethod() + ")");


        if (path.startsWith("/api/")) {
            return true;
        }

        if (path.startsWith("/static/")
            || path.endsWith(".js")
            || path.endsWith(".css")
            || path.endsWith(".ico")
            || path.endsWith(".png")
            || path.endsWith(".jpg")
            || path.endsWith(".jpeg")
            || path.endsWith(".webp")) {
            return true;
        }

        if ("GET".equalsIgnoreCase(request.getMethod())) {
            request.getRequestDispatcher("/").forward(request, response);
            return false;
        }

        return true;
    }
}
