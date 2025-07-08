package com.emfabro.system.filter.wrapper;

import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


public class CustomWrapper {
    public CustomRequestWrapper customReq;
    public CustomResponseWrapper customResp;

    public CustomWrapper(ServletRequest req, ServletResponse resp) {
        this.customReq = new CustomRequestWrapper((HttpServletRequest) req);
        this.customResp = new CustomResponseWrapper((HttpServletResponse) resp);
    }
}
